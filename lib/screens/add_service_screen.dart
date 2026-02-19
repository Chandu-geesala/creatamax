import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../core/api_service.dart';
import '../core/constants.dart';
import '../models/category_model.dart';
import 'booking_calender_screen.dart';

class AddServiceScreen extends StatefulWidget {
  const AddServiceScreen({super.key});

  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _discountController = TextEditingController();
  final _durationController = TextEditingController();

  List<CategoryModel> _categories = [];
  List<SubCategoryModel> _subCategories = [];

  CategoryModel? _selectedCategory;
  SubCategoryModel? _selectedSubCategory;

  File? _imageFile;
  bool _isLoading = false;
  bool _categoriesLoading = true;

  String _startTime = '06:00 AM';
  String _endTime = '12:00 PM';
  List<DateTime> _selectedDates = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final data = await ApiService.getCategories();
      setState(() {
        _categories = data.map((e) => CategoryModel.fromJson(e)).toList();
        _categoriesLoading = false;
      });
    } catch (e) {
      setState(() => _categoriesLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading categories: $e')),
        );
      }
    }
  }

  Future<void> _loadSubCategories(String categoryId) async {
    setState(() => _subCategories = []);
    try {
      final data = await ApiService.getSubCategories(categoryId);
      setState(() {
        _subCategories =
            data.map((e) => SubCategoryModel.fromJson(e)).toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading sub-categories: $e')),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart
          ? const TimeOfDay(hour: 9, minute: 0)
          : const TimeOfDay(hour: 17, minute: 0),
      builder: (context, child) {
        return MediaQuery(
          // ✅ This forces 12hr AM/PM regardless of device setting
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
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
      // ✅ Convert to "09:00 AM" format
      final hour = picked.hourOfPeriod == 0 ? 12 : picked.hourOfPeriod;
      final minute = picked.minute.toString().padLeft(2, '0');
      final period = picked.period == DayPeriod.am ? 'AM' : 'PM';
      final formatted = '${hour.toString().padLeft(2, '0')}:$minute $period';

      setState(() {
        if (isStart) _startTime = formatted;
        else _endTime = formatted;
      });
    }
  }



  Future<void> _openCalendar() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => BookingCalendarScreen(
          selectedDates: _selectedDates,
          startTime: _startTime,
          endTime: _endTime,
        ),
      ),
    );
    if (result != null) {
      setState(() {
        _selectedDates = List<DateTime>.from(result['dates']);
        _startTime = result['startTime'];
        _endTime = result['endTime'];
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }
    if (_selectedDates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select at least one availability date')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final dates = _selectedDates
          .map((d) => DateFormat('yyyy-MM-dd').format(d))
          .toList();

      await ApiService.createService(
        serviceName: _nameController.text.trim(),
        description: _descController.text.trim(),
        category: _selectedCategory!.id,
        subCategory: _selectedSubCategory?.id ?? '',
        price: _priceController.text.trim(),
        duration: _durationController.text.trim(),
        startTime: _startTime,
        endTime: _endTime,
        availabilityDates: dates,
        imageFile: _imageFile,
      );


      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✅ Service created successfully!'),
            backgroundColor: Colors.green[600],
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      'Services & Pricing',
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Picker
              _buildImagePicker()
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: -0.1, end: 0),

              const SizedBox(height: 20),

              // Form Fields
              _buildTextField(
                controller: _nameController,
                label: 'Service Name',
                hint: 'Enter service name',
                validator: (v) =>
                v == null || v.isEmpty ? 'Required' : null,
              ).animate().fadeIn(delay: 100.ms).slideX(begin: 0.1, end: 0),

              const SizedBox(height: 16),

              // Category Dropdown
              _buildLabel('Category'),
              const SizedBox(height: 8),
              _buildCategoryDropdown()
                  .animate()
                  .fadeIn(delay: 200.ms)
                  .slideX(begin: 0.1, end: 0),

              const SizedBox(height: 16),

              // Sub-Category Dropdown
              _buildLabel('Sub-category'),
              const SizedBox(height: 8),
              _buildSubCategoryDropdown()
                  .animate()
                  .fadeIn(delay: 300.ms)
                  .slideX(begin: 0.1, end: 0),

              const SizedBox(height: 16),

              _buildTextField(
                controller: _priceController,
                label: 'Price',
                hint: 'Enter price',
                keyboardType: TextInputType.number,
                validator: (v) =>
                v == null || v.isEmpty ? 'Required' : null,
              ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.1, end: 0),

              const SizedBox(height: 16),

              _buildTextField(
                controller: _discountController,
                label: 'Discount (optional)',
                hint: 'Enter discount',
                keyboardType: TextInputType.number,
              ).animate().fadeIn(delay: 450.ms).slideX(begin: 0.1, end: 0),

              const SizedBox(height: 16),

              _buildTextField(
                controller: _durationController,
                label: 'Duration (minutes)',
                hint: 'E.g. 90',
                keyboardType: TextInputType.number,
                validator: (v) =>
                v == null || v.isEmpty ? 'Required' : null,
              ).animate().fadeIn(delay: 500.ms).slideX(begin: 0.1, end: 0),

              const SizedBox(height: 16),

              _buildTextField(
                controller: _descController,
                label: 'About Business',
                hint: 'Description',
                maxLines: 4,
                validator: (v) =>
                v == null || v.isEmpty ? 'Required' : null,
              ).animate().fadeIn(delay: 550.ms).slideX(begin: 0.1, end: 0),

              const SizedBox(height: 16),



              // Calendar Button
              _buildCalendarButton()
                  .animate()
                  .fadeIn(delay: 650.ms)
                  .scale(begin: const Offset(0.95, 0.95)),

              const SizedBox(height: 8),
              if (_selectedDates.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: _selectedDates
                      .map(
                        (d) => Chip(
                      label: Text(
                        DateFormat('MMM dd').format(d),
                        style: const TextStyle(fontSize: 12),
                      ),
                      backgroundColor:
                      AppConstants.primaryColor.withOpacity(0.1),
                      deleteIconColor: AppConstants.primaryColor,
                      onDeleted: () {
                        setState(() => _selectedDates.remove(d));
                      },
                    ),
                  )
                      .toList(),
                ).animate().fadeIn(delay: 700.ms),

              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 4,
                  ),
                  onPressed: _isLoading ? null : _submitForm,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    'SAVE & CONTINUE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              )
                  .animate()
                  .fadeIn(delay: 750.ms)
                  .slideY(begin: 0.2, end: 0),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: AnimatedContainer(
        duration: 300.ms,
        width: 110,
        height: 110,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppConstants.primaryColor.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppConstants.primaryColor.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: _imageFile != null
            ? ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.file(_imageFile!, fit: BoxFit.cover),
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo_outlined,
                color: AppConstants.primaryColor, size: 32),
            const SizedBox(height: 4),
            Text(
              'Business logo',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 14,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
              BorderSide(color: AppConstants.primaryColor, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: _categoriesLoading
          ? const Padding(
        padding: EdgeInsets.all(14),
        child: LinearProgressIndicator(),
      )
          : DropdownButtonHideUnderline(
        child: DropdownButton<CategoryModel>(
          value: _selectedCategory,
          hint: Text('Select category',
              style:
              TextStyle(color: Colors.grey[400], fontSize: 13)),
          isExpanded: true,
          items: _categories
              .map(
                (c) => DropdownMenuItem(
              value: c,
              child: Text(c.name),
            ),
          )
              .toList(),
          onChanged: (val) {
            setState(() {
              _selectedCategory = val;
              _selectedSubCategory = null;
              _subCategories = [];
            });
            if (val != null) _loadSubCategories(val.id);
          },
          icon: Icon(Icons.keyboard_arrow_down,
              color: AppConstants.primaryColor),
        ),
      ),
    );
  }

  Widget _buildSubCategoryDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<SubCategoryModel>(
          value: _selectedSubCategory,
          hint: Text(
            _selectedCategory == null
                ? 'Select category first'
                : _subCategories.isEmpty
                ? 'Loading...'
                : 'Select sub-category',
            style: TextStyle(color: Colors.grey[400], fontSize: 13),
          ),
          isExpanded: true,
          items: _subCategories
              .map(
                (s) => DropdownMenuItem(
              value: s,
              child: Text(s.name),
            ),
          )
              .toList(),
          onChanged: _subCategories.isEmpty
              ? null
              : (val) => setState(() => _selectedSubCategory = val),
          icon: Icon(Icons.keyboard_arrow_down,
              color: AppConstants.primaryColor),
        ),
      ),
    );
  }

  Widget _buildTimeTile(
      String label, String time, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Icon(Icons.access_time,
                color: AppConstants.primaryColor, size: 18),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        color: Colors.grey[500], fontSize: 11)),
                Text(time,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarButton() {
    return GestureDetector(
      onTap: _openCalendar,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _selectedDates.isEmpty
                ? Colors.grey[300]!
                : AppConstants.primaryColor,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_outlined,
                color: AppConstants.primaryColor, size: 20),
            const SizedBox(width: 12),
            Text(
              _selectedDates.isEmpty
                  ? 'Set Availability Dates'
                  : '${_selectedDates.length} date(s) selected',
              style: TextStyle(
                color: _selectedDates.isEmpty
                    ? Colors.grey[400]
                    : AppConstants.primaryColor,
                fontWeight: _selectedDates.isEmpty
                    ? FontWeight.normal
                    : FontWeight.w600,
              ),
            ),
            const Spacer(),
            Icon(Icons.chevron_right,
                color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
