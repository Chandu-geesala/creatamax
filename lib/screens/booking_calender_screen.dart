import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../core/constants.dart';

class BookingCalendarScreen extends StatefulWidget {
  final List<DateTime> selectedDates;
  final String startTime;
  final String endTime;

  const BookingCalendarScreen({
    super.key,
    required this.selectedDates,
    required this.startTime,
    required this.endTime,
  });

  @override
  State<BookingCalendarScreen> createState() =>
      _BookingCalendarScreenState();
}

class _BookingCalendarScreenState extends State<BookingCalendarScreen> {
  late List<DateTime> _selected;
  DateTime _focusedMonth = DateTime.now();

  // Time slot selection
  String _timeSlot = 'morning'; // any, morning, afternoon, evening, custom

  // These are the actual start/end times sent to API
  String _startTime = '06:00 AM';
  String _endTime = '12:00 PM';

  // Custom slider values (0.0 to 23.99 representing hours)
  double _customStart = 6.0;
  double _customEnd = 12.0;

  @override
  void initState() {
    super.initState();
    _selected = List.from(widget.selectedDates);
    // Parse initial times if passed
    _startTime = widget.startTime.isNotEmpty ? widget.startTime : '06:00 AM';
    _endTime = widget.endTime.isNotEmpty ? widget.endTime : '12:00 PM';
  }

  // ─── Time slot presets ───────────────────────────────────────────
  void _onSlotSelected(String slot) {
    setState(() {
      _timeSlot = slot;
      switch (slot) {
        case 'any':
          _startTime = '12:00 AM';
          _endTime = '11:59 PM';
          _customStart = 0;
          _customEnd = 23.99;
          break;
        case 'morning':
          _startTime = '06:00 AM';
          _endTime = '12:00 PM';
          _customStart = 6;
          _customEnd = 12;
          break;
        case 'afternoon':
          _startTime = '12:00 PM';
          _endTime = '04:00 PM';
          _customStart = 12;
          _customEnd = 16;
          break;
        case 'evening':
          _startTime = '04:00 PM';
          _endTime = '09:00 PM';
          _customStart = 16;
          _customEnd = 21;
          break;
        case 'custom':
        // keep current custom values
          _startTime = _hourToTimeString(_customStart);
          _endTime = _hourToTimeString(_customEnd);
          break;
      }
    });
  }

  // ─── Convert decimal hour to "09:00 AM" format ──────────────────
  String _hourToTimeString(double hour) {
    final h = hour.floor();
    final m = ((hour - h) * 60).round();
    final tod = TimeOfDay(hour: h, minute: m);
    final hh = tod.hourOfPeriod == 0 ? 12 : tod.hourOfPeriod;
    final mm = tod.minute.toString().padLeft(2, '0');
    final period = tod.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hh.toString().padLeft(2, '0')}:$mm $period';
  }

  // ─── Time picker for custom From/To ─────────────────────────────
  Future<void> _pickCustomTime(bool isStart) async {
    final initial = isStart
        ? TimeOfDay(hour: _customStart.floor(), minute: 0)
        : TimeOfDay(hour: _customEnd.floor(), minute: 0);

    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(alwaysUse24HourFormat: false),
          child: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: AppConstants.primaryColor,
              ),
            ),
            child: child!,
          ),
        );
      },
    );

    if (picked != null) {
      final hour = picked.hour.toDouble();
      final formatted = _hourToTimeString(hour);
      setState(() {
        if (isStart) {
          _customStart = hour;
          _startTime = formatted;
          // Ensure end is always after start
          if (_customEnd <= _customStart) {
            _customEnd = _customStart + 1;
            _endTime = _hourToTimeString(_customEnd);
          }
        } else {
          _customEnd = hour;
          _endTime = formatted;
          if (_customEnd <= _customStart) {
            _customStart = _customEnd - 1;
            _startTime = _hourToTimeString(_customStart);
          }
        }
        _timeSlot = 'custom';
      });
    }
  }

  // ─── Calendar helpers ────────────────────────────────────────────
  List<DateTime> _getDaysInMonth(DateTime month) {
    final last = DateTime(month.year, month.month + 1, 0);
    return List.generate(
        last.day, (i) => DateTime(month.year, month.month, i + 1));
  }

  bool _isSelected(DateTime date) =>
      _selected.any((d) => DateUtils.isSameDay(d, date));

  void _toggleDate(DateTime date) {
    setState(() {
      if (_isSelected(date)) {
        _selected.removeWhere((d) => DateUtils.isSameDay(d, date));
      } else {
        _selected.add(date);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final days = _getDaysInMonth(_focusedMonth);
    final firstWeekday =
        DateTime(_focusedMonth.year, _focusedMonth.month, 1).weekday;

    return Scaffold(
      backgroundColor: AppConstants.bgColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90),
        child: Container(
          color: AppConstants.primaryColor,
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: 90,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    padding: const EdgeInsets.only(left: 4, top: 4),
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 16, top: 2, bottom: 8),
                    child: Text(
                      'Booking & Calendar',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),



      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Availability Calendar ──────────────────────────────
            _buildSectionTitle('Availability Calendar'),
            const SizedBox(height: 12),
            _buildCalendar(days, firstWeekday)
                .animate()
                .fadeIn(duration: 400.ms)
                .slideY(begin: -0.05),

            const SizedBox(height: 24),

            // ── Select Time Slot ───────────────────────────────────
            _buildSectionTitle('Select Time Slot'),
            const SizedBox(height: 8),
            _buildTimeSlots(),

            const SizedBox(height: 20),

            // ── Custom Time Range (only active when custom selected) ─
            _buildSectionTitle('Custom Time Range'),
            const SizedBox(height: 12),
            _buildCustomTimeRange()
                .animate()
                .fadeIn(delay: 400.ms),

            const SizedBox(height: 12),

            // ── Selected time summary ──────────────────────────────
            AnimatedContainer(
              duration: 300.ms,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppConstants.primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppConstants.primaryColor.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildTimeBadge('Start Time', _startTime, Icons.login),
                  Container(
                      width: 1, height: 40, color: Colors.grey[300]),
                  _buildTimeBadge('End Time', _endTime, Icons.logout),
                ],
              ),
            ).animate().fadeIn(delay: 500.ms),

            const SizedBox(height: 32),

            // ── Confirm Button ─────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _selected.isEmpty
                    ? null
                    : () {
                  Navigator.pop(context, {
                    'dates': _selected,
                    'startTime': _startTime,
                    'endTime': _endTime,
                  });
                },
                child: Text(
                  _selected.isEmpty
                      ? 'Select at least 1 date'
                      : 'Confirm ${_selected.length} Date(s)  •  $_startTime - $_endTime',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
                .animate()
                .fadeIn(delay: 600.ms)
                .scale(begin: const Offset(0.95, 0.95)),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ─── Calendar Widget ─────────────────────────────────────────────
  Widget _buildCalendar(List<DateTime> days, int firstWeekday) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Month navigator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => setState(() {
                  _focusedMonth =
                      DateTime(_focusedMonth.year, _focusedMonth.month - 1);
                }),
                icon: const Icon(Icons.chevron_left),
              ),
              Row(
                children: [
                  DropdownButton<int>(
                    value: _focusedMonth.month,
                    underline: const SizedBox(),
                    items: List.generate(
                      12,
                          (i) => DropdownMenuItem(
                        value: i + 1,
                        child: Text(
                          DateFormat.MMMM().format(DateTime(0, i + 1)),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    onChanged: (v) => setState(() {
                      _focusedMonth = DateTime(_focusedMonth.year, v!);
                    }),
                  ),
                  DropdownButton<int>(
                    value: _focusedMonth.year,
                    underline: const SizedBox(),
                    items: List.generate(
                      5,
                          (i) => DropdownMenuItem(
                        value: DateTime.now().year + i,
                        child: Text(
                          '${DateTime.now().year + i}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    onChanged: (v) => setState(() {
                      _focusedMonth = DateTime(v!, _focusedMonth.month);
                    }),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => setState(() {
                  _focusedMonth =
                      DateTime(_focusedMonth.year, _focusedMonth.month + 1);
                }),
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Weekday headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su']
                .map((d) => SizedBox(
              width: 36,
              child: Center(
                child: Text(d,
                    style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ),
            ))
                .toList(),
          ),
          const SizedBox(height: 8),
          // Date grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              childAspectRatio: 1,
            ),
            itemCount: (firstWeekday - 1) + days.length,
            itemBuilder: (context, index) {
              if (index < firstWeekday - 1) return const SizedBox();
              final date = days[index - (firstWeekday - 1)];
              final isSelected = _isSelected(date);
              final isToday = DateUtils.isSameDay(date, DateTime.now());

              // ✅ Past date check — before today
              final isPast = date.isBefore(
                DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
              );

              return GestureDetector(
                onTap: isPast ? null : () => _toggleDate(date), // ✅ disabled if past
                child: AnimatedContainer(
                  duration: 200.ms,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppConstants.primaryColor
                        : isToday
                        ? AppConstants.primaryColor.withOpacity(0.15)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${date.day}',
                      style: TextStyle(
                        // ✅ Past dates shown in light grey
                        color: isPast
                            ? Colors.grey[350]
                            : isSelected
                            ? Colors.white
                            : isToday
                            ? AppConstants.primaryColor
                            : Colors.black87,
                        fontWeight: isSelected || isToday
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: 13,
                        // ✅ Strikethrough on past dates
                        decoration: isPast ? TextDecoration.lineThrough : null,
                        decorationColor: Colors.grey[350],
                      ),
                    ),
                  ),
                ),
              );
            },



          ),
        ],
      ),
    );
  }

  // ─── Time Slot Radio Buttons ──────────────────────────────────────
  Widget _buildTimeSlots() {
    final slots = [
      {'value': 'any', 'label': 'Any'},
      {'value': 'morning', 'label': 'Morning (6 AM - 12 PM)'},
      {'value': 'afternoon', 'label': 'Afternoon (12 PM - 4 PM)'},
      {'value': 'evening', 'label': 'Evening (4 PM - 9 PM)'},
      {'value': 'custom', 'label': 'Custom Time Range'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: slots.asMap().entries.map((entry) {
          final slot = entry.value;
          final isLast = entry.key == slots.length - 1;
          return Column(
            children: [
              RadioListTile<String>(
                value: slot['value']!,
                groupValue: _timeSlot,
                onChanged: (v) => _onSlotSelected(v!),
                title: Text(
                  slot['label']!,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: _timeSlot == slot['value']
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: _timeSlot == slot['value']
                        ? AppConstants.primaryColor
                        : Colors.black87,
                  ),
                ),
                activeColor: AppConstants.primaryColor,
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 12),
              ),
              if (!isLast)
                Divider(height: 1, color: Colors.grey[100]),
            ],
          );
        }).toList(),
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  // ─── Custom Time Range Slider + Clock pickers ─────────────────────
  Widget _buildCustomTimeRange() {
    final isCustom = _timeSlot == 'custom';

    return AnimatedOpacity(
      opacity: isCustom ? 1.0 : 0.4,
      duration: 300.ms,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCustom
                ? AppConstants.primaryColor.withOpacity(0.4)
                : Colors.grey[200]!,
            width: isCustom ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            // ✅ Range Slider — linked to hours 0-24
            RangeSlider(
              values: RangeValues(
                _customStart.clamp(0, 23),
                _customEnd.clamp(1, 24),
              ),
              min: 0,
              max: 24,
              divisions: 48, // every 30 mins
              activeColor: AppConstants.primaryColor,
              inactiveColor: AppConstants.primaryColor.withOpacity(0.2),
              labels: RangeLabels(
                _hourToTimeString(_customStart),
                _hourToTimeString(_customEnd),
              ),
              onChanged: isCustom
                  ? (values) {
                if (values.end > values.start) {
                  setState(() {
                    _customStart = values.start;
                    _customEnd = values.end;
                    _startTime = _hourToTimeString(_customStart);
                    _endTime = _hourToTimeString(_customEnd);
                    _timeSlot = 'custom';
                  });
                }
              }
                  : null,
            ),

            const SizedBox(height: 12),

            // ✅ From / To clock tap fields
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: isCustom ? () => _pickCustomTime(true) : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppConstants.bgColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('From',
                                  style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 11)),
                              Text(
                                _startTime,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: isCustom
                                      ? AppConstants.primaryColor
                                      : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                          Icon(Icons.access_time_rounded,
                              color: AppConstants.primaryColor, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: isCustom ? () => _pickCustomTime(false) : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppConstants.bgColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('To',
                                  style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 11)),
                              Text(
                                _endTime,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: isCustom
                                      ? AppConstants.primaryColor
                                      : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                          Icon(Icons.access_time_rounded,
                              color: AppConstants.primaryColor, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildTimeBadge(String label, String time, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppConstants.primaryColor, size: 18),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(color: Colors.grey[500], fontSize: 11)),
        Text(time,
            style: TextStyle(
              color: AppConstants.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            )),
      ],
    );
  }
}
