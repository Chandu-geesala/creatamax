import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import '../core/api_service.dart';
import '../core/constants.dart';
import '../models/service_model.dart';
import '../widgets/animated_service_card.dart';
import 'add_service_screen.dart';

class ManageServicesScreen extends StatefulWidget {
  const ManageServicesScreen({super.key});

  @override
  State<ManageServicesScreen> createState() => _ManageServicesScreenState();
}

class _ManageServicesScreenState extends State<ManageServicesScreen> {
  List<ServiceModel> _services = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await ApiService.getServices();
      print('✅ Services count: ${data.length}');
      setState(() {
        _services = data.map((e) => ServiceModel.fromJson(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Load services error: $e');
      setState(() {
        _error = e.toString(); // This now shows the REAL error on screen
        _isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.bgColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100), // ✅ Taller to fit 2 rows
        child: Container(
          color: AppConstants.primaryColor,
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ Row 1: Back arrow only
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                  padding: const EdgeInsets.only(left: 4),
                ),

                // ✅ Row 2: Title + Add Services button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Manage Services',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const AddServiceScreen()),
                          );
                          if (result == true) _loadServices();
                        },
                        child: const Text(
                          'Add Services',
                          style: TextStyle(
                            color: Colors.orangeAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),


      body: RefreshIndicator(
        onRefresh: _loadServices,
        color: AppConstants.primaryColor,
        child: _isLoading
            ? _buildShimmer()
            : _error != null
            ? _buildError()
            : _services.isEmpty
            ? _buildEmpty()
            : ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: _services.length,
          itemBuilder: (context, index) {
            return AnimatedServiceCard(
              service: _services[index],
              index: index,
              onEdit: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Edit coming soon')),
                );
              },
              onDelete: () => _confirmDelete(index),
            );
          },
        ),
      ),

    );
  }

  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Service'),
        content: Text(
            'Are you sure you want to delete "${_services[index].serviceName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent),
            onPressed: () {
              Navigator.pop(context);
              setState(() => _services.removeAt(index));
            },
            child:
            const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: 5,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          height: 90,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.home_repair_service,
              size: 80, color: AppConstants.primaryColor.withOpacity(0.3))
              .animate()
              .scale(duration: 600.ms, curve: Curves.elasticOut),
          const SizedBox(height: 16),
          const Text('No services yet',
              style: TextStyle(fontSize: 18, color: Colors.grey)),
          const SizedBox(height: 8),
          const Text('Tap the button below to add your first service',
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
          const SizedBox(height: 12),
          const Text('Failed to load services'),
          TextButton(onPressed: _loadServices, child: const Text('Retry')),
        ],
      ),
    );
  }
}
