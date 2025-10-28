import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:hrms_face_recognization/screens/face_detection/service/face_detection_service.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../models/employee_model.dart';
import 'employee_controller.dart';

class FaceDetectionController extends GetxController {
  final Rxn<CameraController> _cameraController = Rxn<CameraController>();
  final employeeController = Get.put(EmployeeController());

  CameraController? get cameraController => _cameraController.value;

  // Observable states
  final isPopupOpen = false.obs;
  final isFaceRegistered = false.obs;
  final isProcessing = false.obs;
  final deletionSuccess = false.obs;
  final apiMessage = ''.obs;
  final isFaceDetected = false.obs;
  final showCamera = false.obs;
  final isRegistrationMode = false.obs;
  final isCameraInitialized = false.obs;
  final selectedEmployeeId = Rxn<String>();
  final selectedEmployeeName = Rxn<String>();
  final recognizedName = Rxn<String>();
  final recognizedCode = Rxn<String>();
  final recognitionSuccess = Rxn<bool>();
  final enteredEmpCode = ''.obs;
  final deletingEmployeeId = Rxn<String>();

  final apiTimer = 3.obs; // default duration



  bool _isStreamActive = false;
  DateTime? lastRecognitionTime;

  @override
  void onClose() {
    _cameraController.value?.dispose();
    super.onClose();
  }

  Future<void> initializeCamera() async {
    try {
      isCameraInitialized.value = false;
      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        _showError('No cameras found on this device');
        return;
      }

      final frontCamera = cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await controller.initialize();
      _cameraController.value = controller;
      isCameraInitialized.value = true;

      print('✅ Camera initialized successfully');

      if (!isRegistrationMode.value) startAutoRecognition();
    } catch (e) {
      print('❌ Camera initialization error: $e');
      _showError('Failed to initialize camera: $e');
      isCameraInitialized.value = false;
    }
  }

  void startAutoRecognition() {
    if (_isStreamActive) return;
    _isStreamActive = true;
    _startFaceDetectionStream();
  }
  void updateApiTimer(dynamic value) {
    try {
      if (value == null) return;
      final parsedValue = int.tryParse(value.toString()) ?? 3;
      apiTimer.value = parsedValue;
      print('⏱️ API timer updated to ${apiTimer.value} seconds');
    } catch (e) {
      print('⚠️ Failed to update API timer: $e');
    }
  }
  Future<void> _startFaceDetectionStream() async {
    final faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableContours: false,
        enableClassification: false,
        enableTracking: false,
        minFaceSize: 0.15,
        performanceMode: FaceDetectorMode.fast,
      ),
    );

    while (showCamera.value && _cameraController.value != null) {
      if (!_cameraController.value!.value.isInitialized) {
        await Future.delayed(const Duration(milliseconds: 100));
        continue;
      }

      try {
        final image = await _cameraController.value!.takePicture();
        final inputImage = InputImage.fromFilePath(image.path);
        final faces = await faceDetector.processImage(inputImage);
        await File(image.path).delete();

        isFaceDetected.value = faces.isNotEmpty;

        // Only recognize if face detected, not processing, no popup, and cooldown passed
        if (faces.isNotEmpty &&
            !isProcessing.value &&
            !isPopupOpen.value &&
            _canRecognize()) {
          print('👤 Face detected! Triggering recognition...');
          await captureAndRecognize();
        }

        await Future.delayed(const Duration(milliseconds: 500));
      } catch (e) {
        print('❌ Face detection error: $e');
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }

    await faceDetector.close();
    _isStreamActive = false;
    isFaceDetected.value = false;
  }

  bool _canRecognize() {
    return lastRecognitionTime == null ||
        DateTime.now().difference(lastRecognitionTime!) > const Duration(seconds: 3);
  }

  Future<void> captureAndRecognize() async {

    if (isProcessing.value || isPopupOpen.value || _cameraController.value == null) return;
    if (!_cameraController.value!.value.isInitialized) return;
    if (!_canRecognize()) return;
    if (isPopupOpen.value) {
      print('🚫 Popup is open — skipping capture');
      return;
    }
    isProcessing.value = true;
    File? file;

    try {
      final image = await _cameraController.value!.takePicture();
      file = File(image.path);
      print('📸 Captured image: ${image.path}');

      final result = await FaceRecognitionService.recognizeFace(imageFile: file);
      lastRecognitionTime = DateTime.now();

      print('📊 Recognition result: $result');

      final punchSuccess = result['success'] == true;
      final faceRecognized = result['recognized'] == true;
      final message = (result['message'] ?? '').toString().toLowerCase();

      recognizedName.value = result['emp_name'] ?? 'Unknown';
      recognizedCode.value = result['emp_code'] ?? 'N/A';
      apiMessage.value = result['message'] ?? '';
      recognitionSuccess.value = punchSuccess;

      if (faceRecognized) {
        print('✅ Face recognized: ${recognizedName.value}');

        // Handle early checkout
        if (message.contains('early checkout')) {
          isProcessing.value = false;
          enteredEmpCode.value = ''; // Clear for auto-recognition
          final confirmed = await _showEarlyCheckoutDialog();

          if (confirmed == true) {
            print('✅ Early checkout confirmed');
            isProcessing.value = true;
            _clearRecognitionState();
            await _confirmEarlyCheckout(file);
          } else {
            print('❌ Early checkout cancelled');
            _clearRecognitionState();
          }
          return;
        }

        // Show success result
        
      } else {
        // Handle unrecognized face with show_popup check
        print('❌ Face not recognized');
        final showPopup = result['show_popup'] == true;

        if (showPopup) {
          recognitionSuccess.value = false;
          apiMessage.value = result['message'] ?? 'Face not recognized';
          await Future.delayed(const Duration(seconds: 1));
          isProcessing.value = false;

          final empCode = await _showEmployeeCodeDialog();

          if (empCode != null && empCode.isNotEmpty) {
            await _handleManualRecognition(file, empCode);
          } else {
            print('❌ User cancelled code entry');
            _clearRecognitionState();
          }
        } else {
          // Just show the error message without popup
          recognitionSuccess.value = false;
          apiMessage.value = result['message'] ?? 'Recognition failed';
          
        }
      }
    } catch (e, stackTrace) {
      print('❌ Recognition error: $e\n$stackTrace');
      recognitionSuccess.value = false;
      apiMessage.value = 'Error: $e';
      
    } finally {
      isProcessing.value = false;
      await _deleteFile(file);
    }
  }

  Future<void> _handleManualRecognition(File file, String empCode) async {
    print('📝 Employee code entered: $empCode');
    isProcessing.value = true;
    enteredEmpCode.value = empCode; // Store the entered code

    try {
      final result = await FaceRecognitionService.recognizeFace(
        imageFile: file,
        empCode: empCode,
      );

      print('📥 Manual recognition result: $result');

      final success = result['success'] == true;
      final faceRecognized = result['recognized'] == true;
      final message = (result['message'] ?? '').toString().toLowerCase();

      recognizedName.value = result['emp_name'] ?? 'Unknown';
      recognizedCode.value = result['emp_code'] ?? 'N/A';
      recognitionSuccess.value = success;
      apiMessage.value = result['message'] ?? '';

      // ✅ Detect Early Checkout
      if (message.contains('early checkout')) {
        isProcessing.value = false;
        final confirmed = await _showEarlyCheckoutDialog();

        if (confirmed == true) {
          print('✅ Early checkout confirmed (manual)');
          isProcessing.value = true;
          _clearRecognitionState();
          await _confirmEarlyCheckout(file, empCode: empCode);
        } else {
          print('❌ Early checkout cancelled (manual)');
          _clearRecognitionState();
        }
        return;
      }

      // ✅ Normal success/failure path
      if (success || faceRecognized) {
        print('✅ Manual recognition successful');
        
      } else {
        print('❌ Invalid employee code');
        apiMessage.value = result['message'] ?? 'Invalid employee code';
        
      }
    } catch (e, stackTrace) {
      print('❌ Manual recognition error: $e\n$stackTrace');
      recognitionSuccess.value = false;
      apiMessage.value = 'Error verifying code';
      
    } finally {
      isProcessing.value = false;
    }
  }


  Future<String?> _showEmployeeCodeDialog() async {
    isPopupOpen.value = true;
    final controller = TextEditingController();

    final result = await Get.dialog<String>(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: Get.width * 0.85,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_off_rounded, size: 40, color: Colors.orange),
              ),
              const SizedBox(height: 16),
              const Text(
                'Face Not Recognized',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please enter your employee code for check-in',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: controller,
                autofocus: true,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.text,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: 2),
                decoration: InputDecoration(
                  hintText: 'Enter Code',
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.normal, letterSpacing: 0),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(result: null),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Cancel', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black54)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final code = controller.text.trim();
                        if (code.isEmpty) {
                          Get.snackbar('Error', 'Please enter employee code',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                            margin: const EdgeInsets.all(16),
                            borderRadius: 12,
                          );
                          return;
                        }
                        Get.back(result: code);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Submit', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    isPopupOpen.value = false;
    return result;
  }

  Future<bool?> _showEarlyCheckoutDialog() async {
    isPopupOpen.value = true;

    final result = await Get.dialog<bool>(
      CupertinoAlertDialog(
        title: const Text('Early Checkout'),
        content: Obx(() {
          final code = enteredEmpCode.value;
          return Text(
            code.isNotEmpty
                ? 'Do you want to proceed with early checkout for $code?'
                : 'Do you want to proceed with early checkout?',
          );
        }),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('No')),
          TextButton(
            onPressed: () {
              // ✅ Return true to proceed
              Get.back(result: true);
            },
            child: const Text('Yes'),
          ),
        ],
      ),
      barrierDismissible: false,
    );

    isPopupOpen.value = false;
    return result;
  }


  Future<void> _confirmEarlyCheckout(File imageFile, {String? empCode}) async {
    try {
      print('⏰ Confirming early checkout...');

      final result = await FaceRecognitionService.recognizeFace(
        imageFile: imageFile,
        earlyCheckout: "yes",
        empCode: empCode, // Send empCode if provided
      );

      print('📥 Early checkout response: $result');

      recognitionSuccess.value = result['success'] == true || result['recognized'] == true;
      apiMessage.value = result['message'] ?? (recognitionSuccess.value! ? 'Early checkout successful' : 'Early checkout failed');

      
    } catch (e, stackTrace) {
      print('❌ Early checkout error: $e\n$stackTrace');
      recognitionSuccess.value = false;
      apiMessage.value = 'Early checkout error: $e';
      
    } finally {
      enteredEmpCode.value = ''; // Clear after use
    }
  }

  Future<void> captureAndRegister() async {
    if (selectedEmployeeId.value == null) {
      _showError('Please select an employee first');
      return;
    }

    if (_cameraController.value == null || !_cameraController.value!.value.isInitialized) {
      _showError('Camera not ready');
      return;
    }

    isProcessing.value = true;
    File? file;

    try {
      final image = await _cameraController.value!.takePicture();
      file = File(image.path);
      print('📸 Captured for registration: ${image.path}');

      final result = await FaceRecognitionService.registerFace(
        empId: selectedEmployeeId.value!,
        imageFile: file,
      );

      if (result['success'] == true) {
        await employeeController.refreshEmployees();
        recognitionSuccess.value = true;
        apiMessage.value = result['message'] ?? 'Face registered successfully!';
        print('✅ Face registered successfully');
        await Future.delayed(const Duration(seconds: 3));
        await closeCamera();
      } else {
        recognitionSuccess.value = false;
        apiMessage.value = result['message'] ?? 'Registration failed';
        print('❌ Registration failed: ${result['message']}');
        
      }
    } catch (e) {
      print('❌ Registration error: $e');
      recognitionSuccess.value = false;
      apiMessage.value = 'Registration error: $e';
      
    } finally {
      isProcessing.value = false;
      await _deleteFile(file);
    }
  }

  Future<void> deleteFace({required String empId}) async {
    if (isProcessing.value) return;

    isProcessing.value = true;
    deletionSuccess.value = false;
    apiMessage.value = '';

    try {
      final success = await FaceRecognitionService.deleteFace(empId: empId);
      deletionSuccess.value = success;
      apiMessage.value = success ? 'Face deleted successfully' : 'Failed to delete face';
      print(success ? '✅ Face deleted for $empId' : '⚠️ Failed to delete face for $empId');
      await Future.delayed(const Duration(seconds: 3));
    } catch (e, stack) {
      print('❌ Error deleting face: $e\n$stack');
      deletionSuccess.value = false;
      apiMessage.value = 'Error deleting face';
      await Future.delayed(const Duration(seconds: 3));
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> onEmployeeSelected(EmployeeData employee) async {
    if (employee.empId.isEmpty || employee.empName.isEmpty) {
      _showError('Invalid employee data');
      return;
    }

    print('👤 Employee selected: ${employee.empName} (ID: ${employee.empId})');
    selectedEmployeeId.value = employee.empId;
    selectedEmployeeName.value = employee.empName;
    showCamera.value = true;
    await initializeCamera();
  }

  Future<void> closeCamera() async {
    print('🔒 Closing camera...');
    _isStreamActive = false;
    await _cameraController.value?.dispose();
    _cameraController.value = null;
    isCameraInitialized.value = false;
    showCamera.value = false;
    selectedEmployeeId.value = null;
    selectedEmployeeName.value = null;
    isFaceDetected.value = false;
    _clearRecognitionState();
    print('✅ Camera closed');
  }

  Future<void> openCamera() async {
    print('📷 Opening camera for auto recognition...');
    showCamera.value = true;
    await initializeCamera();
  }

  void setRegistrationMode(bool value) {
    print('🔄 Setting registration mode: $value');
    isRegistrationMode.value = value;
  }

  // Helper methods
  void _clearRecognitionState() {
    recognitionSuccess.value = null;
    recognizedName.value = null;
    recognizedCode.value = null;
  }

  // Future<void> _delayedClear(int seconds) async {
  //   await Future.delayed(Duration(seconds: seconds));
  //   _clearRecognitionState();
  // }

  Future<void> _deleteFile(File? file) async {
    try {
      await file?.delete();
    } catch (_) {}
  }

  void _showError(String message) {
    Get.snackbar('Error', message, snackPosition: SnackPosition.BOTTOM);
  }
}