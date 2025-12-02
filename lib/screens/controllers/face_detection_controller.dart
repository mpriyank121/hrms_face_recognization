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
  final isFaceInCircle = false.obs;
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

  // NEW: Track if result widget is being displayed
  final isResultDisplayed = false.obs;

  final apiTimer = 3.obs;

  bool _isStreamActive = false;
  bool _wasFaceInCircle = false;
  DateTime? lastRecognitionTime;
  DateTime? _blockUntil;

  // Constants
  static const int BLOCK_DURATION_MS = 2000;
  static const int MIN_RECOGNITION_INTERVAL_MS = 2000;

  @override
  void onClose() {
    _cameraController.value?.dispose();
    super.onClose();
  }

  /// Block all API calls for specified duration
  void blockAPICalls({String reason = 'UI interaction'}) {
    _blockUntil = DateTime.now().add(Duration(milliseconds: BLOCK_DURATION_MS));
    print('🚫 API BLOCKED for ${BLOCK_DURATION_MS}ms - Reason: $reason');
  }

  /// Check if API calls are currently blocked
  bool get isAPIBlocked {
    if (_blockUntil == null) return false;

    final now = DateTime.now();
    if (now.isBefore(_blockUntil!)) {
      final remaining = _blockUntil!.difference(now).inMilliseconds;
      print('⏳ API still blocked for ${remaining}ms');
      return true;
    }

    _blockUntil = null;
    return false;
  }

  /// Check if we can make an API call
  bool get canMakeAPICall {
    // NEW: Block if result is being displayed
    if (isResultDisplayed.value) {
      print('🚫 Cannot call API - Result widget is displayed');
      return false;
    }

    // Check if blocked by timer
    if (isAPIBlocked) return false;

    // Check if popup is open
    if (isPopupOpen.value) {
      print('🚫 Cannot call API - Popup is open');
      return false;
    }

    // Check if processing
    if (isProcessing.value) {
      print('🚫 Cannot call API - Already processing');
      return false;
    }

    // Check minimum time between recognitions
    if (lastRecognitionTime != null) {
      final timeSince = DateTime.now().difference(lastRecognitionTime!).inMilliseconds;
      if (timeSince < MIN_RECOGNITION_INTERVAL_MS) {
        print('🚫 Cannot call API - Too soon since last recognition (${timeSince}ms)');
        return false;
      }
    }

    return true;
  }

  /// Called when result widget appears
  void onResultDisplayed() {
    isResultDisplayed.value = true;
    print('🎭 Result widget DISPLAYED - Freezing all operations');
  }

  /// Called when result widget disappears
  void onResultCleared() {
    isResultDisplayed.value = false;
    Future.delayed(const Duration(seconds: 1), () {
    });
  }

  /// Check if face is within the circular boundary
  bool _isFaceInCircleBoundary(Face face, Size imageSize) {
    final screenWidth = Get.width;
    final screenHeight = Get.height;

    final circleCenterX = screenWidth / 2;
    final circleCenterY = screenHeight / 2.5;
    final circleRadius = screenWidth * 0.35;

    final faceRect = face.boundingBox;

    final scaleX = screenWidth / imageSize.width;
    final scaleY = screenHeight / imageSize.height;

    final faceCenterX = (faceRect.left + faceRect.width / 2) * scaleX;
    final faceCenterY = (faceRect.top + faceRect.height / 2) * scaleY;

    final dx = faceCenterX - circleCenterX;
    final dy = faceCenterY - circleCenterY;
    final distance = (dx * dx + dy * dy).abs().toDouble();
    final distanceFromCenter = distance > 0 ? distance : 0.0;

    final isInside = distanceFromCenter <= (circleRadius * circleRadius);

    final faceSize = faceRect.width * scaleX;
    final isGoodSize = faceSize > screenWidth * 0.25 && faceSize < screenWidth * 0.7;

    return isInside && isGoodSize;
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

      if (!isRegistrationMode.value) {
        await Future.delayed(const Duration(seconds: 1));
        startAutoRecognition();
      }
    } catch (e) {
      print('❌ Camera initialization error: $e');
      _showError('Failed to initialize camera: $e');
      isCameraInitialized.value = false;
    }
  }

  void startAutoRecognition() {
    if (_isStreamActive) return;
    _isStreamActive = true;
    _wasFaceInCircle = false;
    print('🎬 Starting auto recognition stream');
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
        enableTracking: true,
        minFaceSize: 0.15,
        performanceMode: FaceDetectorMode.fast,
      ),
    );

    print('👁️ Face detection stream started');

    while (showCamera.value && _cameraController.value != null) {
      try {
        // NEW: Skip detection if result is being displayed
        if (isResultDisplayed.value) {
          print('⏸️ Detection paused - Result displayed');
          await Future.delayed(const Duration(milliseconds: 500));
          continue;
        }

        if (!_cameraController.value!.value.isInitialized) {
          await Future.delayed(const Duration(milliseconds: 200));
          continue;
        }

        final image = await _cameraController.value!.takePicture();
        final inputImage = InputImage.fromFilePath(image.path);
        final faces = await faceDetector.processImage(inputImage);

        final imageFile = File(image.path);
        final imageBytes = await imageFile.readAsBytes();
        final decodedImage = await decodeImageFromList(imageBytes);
        final imageSize = Size(decodedImage.width.toDouble(), decodedImage.height.toDouble());

        await imageFile.delete();

        final faceCount = faces.length;

        if (faceCount == 0) {
          isFaceDetected.value = false;
          isFaceInCircle.value = false;
          _wasFaceInCircle = false;
          await Future.delayed(const Duration(milliseconds: 500));
          continue;
        }

        if (faceCount > 1) {
          print('⚠️ Multiple faces detected (${faceCount}) - skipping recognition');
          isFaceDetected.value = true;
          isFaceInCircle.value = false;
          _wasFaceInCircle = false;
          await Future.delayed(const Duration(milliseconds: 500));
          continue;
        }

        final face = faces.first;
        final isInCircle = _isFaceInCircleBoundary(face, imageSize);

        isFaceDetected.value = true;
        isFaceInCircle.value = isInCircle;

        if (isInCircle) {
          print('🎯 Face is IN the circle');

          if (!_wasFaceInCircle && canMakeAPICall) {
            print('✨ Face ENTERED circle - triggering recognition!');
            _wasFaceInCircle = true;
            await captureAndRecognize();
          } else if (_wasFaceInCircle) {
            print('👤 Face still in circle - waiting');
          }
        } else {
          print('❌ Face is OUTSIDE the circle');
          _wasFaceInCircle = false;
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
    isFaceInCircle.value = false;
    _wasFaceInCircle = false;
    print('👁️ Face detection stream stopped');
  }

  Future<void> captureAndRecognize() async {
    if (!canMakeAPICall) {
      print('🚫 captureAndRecognize blocked - conditions not met');
      return;
    }

    if (_cameraController.value == null || !_cameraController.value!.value.isInitialized) {
      print('🚫 Camera not ready');
      return;
    }

    print('📸 Starting capture and recognize...');
    isProcessing.value = true;
    blockAPICalls(reason: 'Recognition started');
    File? file;

    try {
      final image = await _cameraController.value!.takePicture();
      file = File(image.path);
      print('📸 Image captured: ${image.path}');

      final result = await FaceRecognitionService.recognizeFace(imageFile: file);
      lastRecognitionTime = DateTime.now();

      print('📊 Recognition API response: $result');

      final punchSuccess = result['success'] == true;
      final faceRecognized = result['recognized'] == true;
      final message = (result['message'] ?? '').toString().toLowerCase();

      recognizedName.value = result['emp_name'] ?? 'Unknown';
      recognizedCode.value = result['emp_code'] ?? 'N/A';
      apiMessage.value = result['message'] ?? '';
      recognitionSuccess.value = punchSuccess;

      blockAPICalls(reason: 'Showing recognition result');

      if (faceRecognized) {
        print('✅ Face recognized: ${recognizedName.value}');

        if (message.contains('early checkout')) {
          isProcessing.value = false;
          enteredEmpCode.value = '';

          blockAPICalls(reason: 'Early checkout dialog');
          final confirmed = await _showEarlyCheckoutDialog();
          blockAPICalls(reason: 'Early checkout dialog closed');

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
      } else {
        print('❌ Face not recognized');
        final showPopup = result['show_popup'] == true;

        if (showPopup) {
          recognitionSuccess.value = false;
          apiMessage.value = result['message'] ?? 'Face not recognized';

          await Future.delayed(const Duration(seconds: 1));
          isProcessing.value = false;

          blockAPICalls(reason: 'Employee code dialog');
          final empCode = await _showEmployeeCodeDialog();

          blockAPICalls(reason: 'Employee code dialog closed');

          if (empCode != null && empCode.isNotEmpty) {
            await _handleManualRecognition(file, empCode);
          } else {
            print('❌ User cancelled code entry');
            _clearRecognitionState();
          }
        } else {
          recognitionSuccess.value = false;
          apiMessage.value = result['message'] ?? 'Recognition failed';
        }
      }
    } catch (e, stackTrace) {
      print('❌ Recognition error: $e\n$stackTrace');
      recognitionSuccess.value = false;
      apiMessage.value = 'Error: $e';
      blockAPICalls(reason: 'Error occurred');
    } finally {
      isProcessing.value = false;
      await _deleteFile(file);
      print('✅ Recognition cycle complete');
    }
  }

  Future<void> _handleManualRecognition(File file, String empCode) async {
    print('📝 Manual recognition with employee code: $empCode');
    isProcessing.value = true;
    enteredEmpCode.value = empCode;
    blockAPICalls(reason: 'Manual recognition');

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

      blockAPICalls(reason: 'Manual recognition result shown');

      if (message.contains('early checkout')) {
        isProcessing.value = false;

        blockAPICalls(reason: 'Early checkout dialog (manual)');
        final confirmed = await _showEarlyCheckoutDialog();
        blockAPICalls(reason: 'Early checkout dialog closed (manual)');

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
      blockAPICalls(reason: 'Manual recognition error');
    } finally {
      isProcessing.value = false;
    }
  }

  Future<String?> _showEmployeeCodeDialog() async {
    isPopupOpen.value = true;
    print('🔒 Employee code dialog OPENED');

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
                      onPressed: () {
                        Get.back(result: null);
                      },
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
                          blockAPICalls(reason: 'Snackbar shown');
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
    print('🔓 Employee code dialog CLOSED');

    return result;
  }


  Future _showEarlyCheckoutDialog() async {
    isPopupOpen.value = true;
    print('🔒 Early checkout dialog OPENED');

    final result = await Get.dialog(
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

    isPopupOpen.value = false;
    print('🔓 Early checkout dialog CLOSED with result: $result');

    // FIX: Clear result display state when dialog closes
    // This ensures detection resumes even if user pressed "No"
    if (result == false || result == null) {
      print('✅ User cancelled - clearing result display state');
      isResultDisplayed.value = false;
      _clearRecognitionState();
    }

    return result;
  }

  Future<void> _confirmEarlyCheckout(File imageFile, {String? empCode}) async {
    try {
      print('⏰ Confirming early checkout...');
      blockAPICalls(reason: 'Early checkout confirmation');

      final result = await FaceRecognitionService.recognizeFace(
        imageFile: imageFile,
        earlyCheckout: "yes",
        empCode: empCode,
      );

      print('📥 Early checkout response: $result');

      recognitionSuccess.value = result['success'] == true || result['recognized'] == true;
      apiMessage.value = result['message'] ?? (recognitionSuccess.value! ? 'Early checkout successful' : 'Early checkout failed');
      blockAPICalls(reason: 'Early checkout result shown');
    } catch (e, stackTrace) {
      print('❌ Early checkout error: $e\n$stackTrace');
      recognitionSuccess.value = false;
      apiMessage.value = 'Early checkout error: $e';
      blockAPICalls(reason: 'Early checkout error');
    } finally {
      enteredEmpCode.value = '';
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
    blockAPICalls(reason: 'Registration');
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
        blockAPICalls(reason: 'Registration success shown');
        await Future.delayed(const Duration(seconds: 3));
        await closeCamera();
      } else {
        recognitionSuccess.value = false;
        apiMessage.value = result['message'] ?? 'Registration failed';
        print('❌ Registration failed: ${result['message']}');
        blockAPICalls(reason: 'Registration failed shown');
      }
    } catch (e) {
      print('❌ Registration error: $e');
      recognitionSuccess.value = false;
      apiMessage.value = 'Registration error: $e';
      blockAPICalls(reason: 'Registration error');
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
    blockAPICalls(reason: 'Face deletion');

    try {
      final success = await FaceRecognitionService.deleteFace(empId: empId);
      deletionSuccess.value = success;
      apiMessage.value = success ? 'Face deleted successfully' : 'Failed to delete face';
      print(success ? '✅ Face deleted for $empId' : '⚠️ Failed to delete face for $empId');
      blockAPICalls(reason: 'Deletion result shown');
      await Future.delayed(const Duration(seconds: 3));
    } catch (e, stack) {
      print('❌ Error deleting face: $e\n$stack');
      deletionSuccess.value = false;
      apiMessage.value = 'Error deleting face';
      blockAPICalls(reason: 'Deletion error');
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
    blockAPICalls(reason: 'Employee selection');
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
    isFaceInCircle.value = false;
    _wasFaceInCircle = false;
    _clearRecognitionState();
    _blockUntil = null;
    isResultDisplayed.value = false;
    print('✅ Camera closed');
  }

  Future<void> openCamera() async {
    print('📷 Opening camera for auto recognition...');
    showCamera.value = true;
    blockAPICalls(reason: 'Camera opening');
    await initializeCamera();
  }

  void setRegistrationMode(bool value) {
    print('🔄 Setting registration mode: $value');
    isRegistrationMode.value = value;
    blockAPICalls(reason: 'Mode change');
  }

  void _clearRecognitionState() {
    recognitionSuccess.value = null;
    recognizedName.value = null;
    recognizedCode.value = null;
  }

  Future<void> _deleteFile(File? file) async {
    try {
      await file?.delete();
    } catch (_) {}
  }

  void _showError(String message) {
    blockAPICalls(reason: 'Error snackbar');
    Get.snackbar('Error', message, snackPosition: SnackPosition.BOTTOM);
  }
}