import 'package:flutter/material.dart';
import 'core/constants.dart';
import 'screens/manage_services_screen.dart';

void main() {
  runApp(const ServiceManagementApp());
}

class ServiceManagementApp extends StatelessWidget {
  const ServiceManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Service Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: AppConstants.primaryColor,
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: AppConstants.bgColor,
        appBarTheme: AppBarTheme(
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const ManageServicesScreen(),
    );
  }
}
