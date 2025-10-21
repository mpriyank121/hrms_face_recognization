import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hrms_face_recognization/config/App_margin.dart';
import 'package:hrms_face_recognization/core/widgets/bordered_container.dart';
import 'package:hrms_face_recognization/screens/controllers/location_controller.dart';
import 'package:hrms_face_recognization/widgets/custom_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/shared_pref_helper.dart';
import '../controllers/employee_controller.dart';
import '../controllers/face_detection_controller.dart';
import '../widgets/grouped_employee_list.dart';
import '../wlecome_page.dart';
import 'camera_view_screen.dart';

class FaceDetectionScreen extends StatefulWidget {
  final String orgId;
  const FaceDetectionScreen({super.key, required this.orgId});

  @override
  State<FaceDetectionScreen> createState() => _FaceDetectionScreenState();
}

class _FaceDetectionScreenState extends State<FaceDetectionScreen> {
  final employeeController = Get.put(EmployeeController());
  final faceDetectionController = Get.put(FaceDetectionController());
  final locationController = Get.put(LocationController());

  @override
  void initState() {
    super.initState();
    locationController.fetchCurrentLocationWithDetails();

    // Listen to registration mode changes to refresh employees
    ever(faceDetectionController.isRegistrationMode, (isRegistration) {
      if (isRegistration) {
        // Fetch employees when entering registration mode
        employeeController.refreshEmployees();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _handleLogout() async {
    try {
      await SharedPrefHelper.clear();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', false);
      Get.deleteAll(force: true);
      Get.offAllNamed('/welcome');
    } catch (e) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => WelcomePage()),
            (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (faceDetectionController.showCamera.value) {
        return FaceDetectionView();
      }

      if (faceDetectionController.isRegistrationMode.value) {
        return _buildEmployeeList();
      }

      return _buildModeSelection();
    });
  }

  Widget _buildModeSelection() {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: CustomAppBar(
        title: 'Face Recognition',
        showBackButton: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              onPressed: _handleLogout,
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.logout, color: Colors.red, size: 22),
              ),
              tooltip: 'Logout',
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.deepOrange.withOpacity(0.2), Colors.deepOrange[500]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepOrange.withOpacity(0.3),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.face_retouching_natural,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Welcome',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choose your action below',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    BorderedContainer(child: _buildModernModeCard(
                      icon: Icons.person_add_alt_1,
                      title: "Register Face",
                      subtitle: "Add new employee face data",
                      onTap: () {
                        faceDetectionController.setRegistrationMode(true);
                      },
                    ),),
                    const SizedBox(height: 20),
                    BorderedContainer(child: _buildModernModeCard(
                      icon: Icons.login_rounded,
                      title: "Auto Punch In/Out",
                      subtitle: "Quick attendance with face scan",
                      onTap: () async {
                        faceDetectionController.setRegistrationMode(false);
                        await faceDetectionController.openCamera();
                      },
                    ),)
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernModeCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.deepOrange,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, size: 32, color: Colors.white),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.deepOrange,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.deepOrange,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.deepOrange,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeList() {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3748)),
          onPressed: () {
            faceDetectionController.setRegistrationMode(false);
          },
        ),
        title: const Text(
          'Select Employee',
          style: TextStyle(
            color: Color(0xFF2D3748),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: AppMargin(
        child: GroupedEmployeeList(
          employeeController: employeeController,
          onRegisterTap: (employee) async {
            await faceDetectionController.onEmployeeSelected(employee);
            await employeeController.refreshEmployees();
          },
        ),
      ),
    );
  }
}