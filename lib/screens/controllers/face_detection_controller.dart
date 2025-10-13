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
  final isEarlyCheckoutDialogOpen = false.obs;
  var isFaceRegistered = false.obs;
  final RxBool isProcessing = false.obs;
  final RxBool deletionSuccess = false.obs;
  final RxString apiMessage = ''.obs;
  final isFaceDetected = false.obs;
  bool _isStreamActive = false;
  final showCamera = false.obs;
  final isRegistrationMode = false.obs;
  final isCameraInitialized = false.obs;
  final selectedEmployeeId = Rxn<String>();
  final selectedEmployeeName = Rxn<String>();
  final recognizedName = Rxn<String>();
  final recognizedCode = Rxn<String>();
  final recognitionSuccess = Rxn<bool>();


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
        Get.snackbar('Error', 'No cameras found on this device');
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

      // Set the observable camera controller
      _cameraController.value = controller;
      isCameraInitialized.value = true;

      print('Camera initialized successfully');

      // Start auto recognition if not in registration mode
      if (!isRegistrationMode.value) {
        startAutoRecognition();
      }
    } catch (e) {
      print('Camera initialization error: $e');
      Get.snackbar(
        'Camera Error',
        'Failed to initialize camera: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      isCameraInitialized.value = false;
    }
  }

  void startAutoRecognition() {
    if (_isStreamActive) return;
    _isStreamActive = true;

    _startFaceDetectionStream();
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
        // Capture image for detection
        final image = await _cameraController.value!.takePicture();
        final inputImage = InputImage.fromFilePath(image.path);

        // Detect faces
        final faces = await faceDetector.processImage(inputImage);

        // Clean up
        await File(image.path).delete();

        if (faces.isNotEmpty) {
          isFaceDetected.value = true;

          // Only trigger recognition if not already processing
          if (!isProcessing.value &&
              (lastRecognitionTime == null ||
                  DateTime.now().difference(lastRecognitionTime!) > const Duration(seconds: 3))) {
            print('👤 Face detected! Triggering recognition...');
            await captureAndRecognize();
          }
        } else {
          isFaceDetected.value = false;
        }

        // Wait before next detection
        await Future.delayed(const Duration(milliseconds: 500));

      } catch (e) {
        print('Face detection error: $e');
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }

    // Cleanup
    await faceDetector.close();
    _isStreamActive = false;
    isFaceDetected.value = false;
  }
  // Show employee code input dialog when face not recognized
  // Show employee code input dialog when face not recognized
  Future<String?> _showEmployeeCodeDialog() async {
    final TextEditingController empCodeController = TextEditingController();

    return await Get.dialog<String>(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: MediaQuery.of(Get.context!).size.width * 0.85,
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
              // Icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_off_rounded,
                  size: 40,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 16),

              // Title
              const Text(
                'Face Not Recognized',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle
              const Text(
                'Please enter your employee code for check-in',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 24),

              // Text Field
              TextField(
                controller: empCodeController,
                autofocus: true,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.text,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter Code',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.normal,
                    letterSpacing: 0,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.blue,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(result: null),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final code = empCodeController.text.trim();
                        if (code.isEmpty) {
                          Get.snackbar(
                            'Error',
                            'Please enter employee code',
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Submit',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
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
  }

  Future<void> captureAndRecognize() async {
    if (isProcessing.value || _cameraController.value == null) return;

    if (!_cameraController.value!.value.isInitialized) {
      print('Camera not initialized for recognition');
      return;
    }

    if (lastRecognitionTime != null &&
        DateTime.now().difference(lastRecognitionTime!) < const Duration(seconds: 3)) {
      return;
    }

    isProcessing.value = true;

    try {
      final image = await _cameraController.value!.takePicture();
      final file = File(image.path);

      print('Captured image for recognition: ${image.path}');

      final result = await FaceRecognitionService.recognizeFace(imageFile: file);
      lastRecognitionTime = DateTime.now();

      print('📊 Full Result: $result');

      // Determine final success based on punch-in API
      final punchSuccess = result['success'] == true;
      final faceRecognized = result['recognized'] == true;

      recognizedName.value = result['emp_name'] ?? 'Unknown';
      recognizedCode.value = result['emp_code'] ?? 'N/A';
      apiMessage.value = result['message'] ?? '';
      recognitionSuccess.value = punchSuccess;

      if (faceRecognized) {
        print('✅ Face recognized: ${recognizedName.value}');

        // Check for early checkout
        final message = (result['message'] ?? '').toString().toLowerCase();
        if (message.contains('early checkout')) {
          print('🔔 Showing early checkout dialog');
          isProcessing.value = false;

          final shouldEarlyCheckout = await _showEarlyCheckoutDialog();

          if (shouldEarlyCheckout == true) {
            print('✅ User confirmed early checkout');
            isProcessing.value = true;
            _clearRecognitionState();
            await _confirmEarlyCheckout(file);
          } else {
            print('❌ User cancelled early checkout');
            _clearRecognitionState();
          }

          try {
            await file.delete();
          } catch (_) {}

          isProcessing.value = false;
          return;
        }

        // Show result for 3 seconds
        await Future.delayed(const Duration(seconds: 3));
        _clearRecognitionState();
      } else {
        // ❌ Face not recognized - show employee code dialog
        print('❌ Face not recognized');
        recognitionSuccess.value = false;
        apiMessage.value = result['message'] ?? 'Face not recognized';

        await Future.delayed(const Duration(seconds: 1));
        isProcessing.value = false;

        final empCode = await _showEmployeeCodeDialog();
        if (empCode != null && empCode.isNotEmpty) {
          print('📝 Employee code entered: $empCode');
          isProcessing.value = true;

          try {
            final manualResult = await FaceRecognitionService.recognizeFace(
              imageFile: file,
              empCode: empCode,
            );

            print('📥 Manual recognition response: $manualResult');

            // Base success on punch-in API success
            final manualSuccess = manualResult['success'] == true;
            recognitionSuccess.value = manualSuccess;

            recognizedName.value = manualResult['emp_name'] ?? 'Unknown';
            recognizedCode.value = manualResult['emp_code'] ?? 'N/A';
            apiMessage.value = manualResult['message'] ??
                (manualSuccess ? 'Check-in successful' : 'Invalid employee code');

            await Future.delayed(const Duration(seconds: 3));
            _clearRecognitionState();
          } catch (e) {
            print('❌ Manual recognition error: $e');
            recognitionSuccess.value = false;
            apiMessage.value = 'Error verifying code';
            await Future.delayed(const Duration(seconds: 3));
            _clearRecognitionState();
          } finally {
            isProcessing.value = false;
          }
        } else {
          print('❌ User cancelled employee code entry');
          _clearRecognitionState();
        }
      }


      try {
        await file.delete();
      } catch (_) {}

    } catch (e, stackTrace) {
      print('❌ Recognition error: $e');
      print('📍 Stack trace: $stackTrace');

      recognitionSuccess.value = false;
      apiMessage.value = 'Error: $e';
      await Future.delayed(const Duration(seconds: 3));
      _clearRecognitionState();
    } finally {
      isProcessing.value = false;
    }
  }

// Show early checkout confirmation dialog
  Future<bool?> _showEarlyCheckoutDialog() async {
    isEarlyCheckoutDialogOpen.value = true; // ✅ Set flag before showing dialog

    return await Get.dialog<bool>(
      CupertinoAlertDialog(
        title: const Text('Early Checkout'),
        content: const Text('Do you want to proceed with early checkout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Yes'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
  Future<void> _confirmEarlyCheckout(File imageFile) async {
    try {
      print('Confirming early checkout...');

      final result = await FaceRecognitionService.recognizeFace(
        imageFile: imageFile,
        earlyCheckout: "yes",
      );

      print('📥 Early checkout response: $result');

      // ✅ Update recognition state to show the result card
      if (result['success'] == true || result['recognized'] == true) {
        recognitionSuccess.value = true;
        apiMessage.value = result['message'] ?? 'Early checkout successful';
      } else {
        recognitionSuccess.value = false;
        apiMessage.value = result['message'] ?? 'Early checkout failed';
      }

      // ✅ Let the result display for 3 seconds
      await Future.delayed(const Duration(seconds: 3));
      _clearRecognitionState();

    } catch (e, stackTrace) {
      print('❌ Early checkout error: $e');
      print('📍 Stack trace: $stackTrace');

      // ✅ Show error in the result card
      recognitionSuccess.value = false;
      apiMessage.value = 'Early checkout error: $e';

      await Future.delayed(const Duration(seconds: 3));
      _clearRecognitionState();
    }
  }

  Future<void> captureAndRegister() async {
    if (selectedEmployeeId.value == null) {
      Get.snackbar('Error', 'Please select an employee first');
      return;
    }

    if (_cameraController.value == null || !_cameraController.value!.value.isInitialized) {
      Get.snackbar('Error', 'Camera not ready');
      return;
    }

    isProcessing.value = true;

    try {
      final image = await _cameraController.value!.takePicture();
      final file = File(image.path);

      print('Captured image for registration: ${image.path}');

      final result = await FaceRecognitionService.registerFace(
        empId: selectedEmployeeId.value!,
        imageFile: file,
      );

      if (result['success'] == true) {
        await employeeController.refreshEmployees();

        recognitionSuccess.value = true;
        apiMessage.value = result['message'] ?? 'Face registered successfully!';
        print('Face registered successfully');

        await Future.delayed(const Duration(seconds: 3));
        await closeCamera();
      } else {
        recognitionSuccess.value = false;
        apiMessage.value = result['message'] ?? 'Registration failed';
        print('Registration failed: ${result['message']}');
        await Future.delayed(const Duration(seconds: 3));
        _clearRecognitionState();
      }

      try {
        await file.delete();
      } catch (_) {}

    } catch (e) {
      print('Registration error: $e');
      recognitionSuccess.value = false;
      apiMessage.value = 'Registration error: $e';
      await Future.delayed(const Duration(seconds: 3));
      _clearRecognitionState();
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> deleteFace({required String empId}) async {
    if (isProcessing.value) return;

    isProcessing.value = true;
    deletionSuccess.value = false;
    apiMessage.value = '';

    try {
      final success = await FaceRecognitionService.deleteFace(
        empId: empId,
      );

      if (success) {
        deletionSuccess.value = true;
        apiMessage.value = 'Face deleted successfully';
        debugPrint('✅ Face deleted for $empId');
      } else {
        deletionSuccess.value = false;
        apiMessage.value = 'Failed to delete face';
        debugPrint('⚠️ Failed to delete face for $empId');
      }
      // Optional: reset message after a few seconds
      await Future.delayed(const Duration(seconds: 3));

    } catch (e, stack) {
      debugPrint('❌ Error deleting face: $e');
      debugPrint('📚 Stack trace: $stack');
      deletionSuccess.value = false;
      apiMessage.value = 'Error deleting face';
      await Future.delayed(const Duration(seconds: 3));

    } finally {
      isProcessing.value = false;
    }
  }


  void _clearRecognitionState() {
    recognitionSuccess.value = null;

    recognizedName.value = null;
    recognizedCode.value = null;
    isEarlyCheckoutDialogOpen.value = false; // ✅ Reset flag

  }

  Future<void> onEmployeeSelected(EmployeeData employee) async {
    final employeeId = employee.empId;       // Use empId
    final employeeName = employee.empName;   // Use empName

    if (employeeId.isEmpty || employeeName.isEmpty) {
      Get.snackbar('Error', 'Invalid employee data');
      return;
    }

    print('Employee selected: $employeeName (ID: $employeeId)');

    selectedEmployeeId.value = employeeId;
    selectedEmployeeName.value = employeeName;
    showCamera.value = true;

    await initializeCamera();
  }


  Future<void> closeCamera() async {
    print('Closing camera...');

    _isStreamActive = false; // ✅ Stop face detection stream

    await _cameraController.value?.dispose();
    _cameraController.value = null;
    isCameraInitialized.value = false;
    showCamera.value = false;
    selectedEmployeeId.value = null;
    selectedEmployeeName.value = null;
    isFaceDetected.value = false; // ✅ Reset face detection flag
    _clearRecognitionState();

    print('Camera closed');
  }

  void setRegistrationMode(bool value) {
    print('Setting registration mode: $value');
    isRegistrationMode.value = value;
  }

  Future<void> openCamera() async {
    print('Opening camera for auto recognition...');
    showCamera.value = true;
    await initializeCamera();
  }
}