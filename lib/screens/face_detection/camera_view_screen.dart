import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import '../controllers/face_detection_controller.dart';
import '../login/Widgets/avatar_painter.dart';

class FaceDetectionView extends StatefulWidget {
  const FaceDetectionView({Key? key}) : super(key: key);

  @override
  State<FaceDetectionView> createState() => _FaceDetectionViewState();
}

class _FaceDetectionViewState extends State<FaceDetectionView> {
  late final FaceDetectionController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<FaceDetectionController>();
  }

  Future<bool> _handleBackNavigation() async {
    // If in registration mode, allow normal back navigation
    if (controller.isRegistrationMode.value) {
      await controller.closeCamera();
      return true; // Allow navigation
    }

    // If not in registration mode, require PIN
    final shouldExit = await _showPinDialog();
    if (shouldExit == true) {
      await controller.closeCamera();
      return true; // Allow navigation
    }
    return false; // Block navigation
  }

  Future<bool?> _showPinDialog() async {
    final TextEditingController pinController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return PopScope(
          canPop: false, // Prevent dialog dismissal with back button
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: const [
                Icon(Icons.lock, color: Colors.deepOrange),
                SizedBox(width: 12),
                Text(
                  'Enter PIN',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Enter your PIN to exit',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: pinController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 6,
                    autofocus: true,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: InputDecoration(
                      hintText: 'Enter PIN',
                      prefixIcon: const Icon(Icons.pin, color: Colors.deepOrange),
                      counterText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.deepOrange,
                          width: 2,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter PIN';
                      }
                      if (value.length < 4) {
                        return 'PIN must be at least 4 digits';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    final enteredPin = pinController.text;
                    if (_verifyPin(enteredPin)) {
                      Navigator.of(context).pop(true);
                    } else {
                      // Show error
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Incorrect PIN'),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      pinController.clear();
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  'Submit',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  bool _verifyPin(String pin) {
    // TODO: Replace with your actual PIN verification logic
    const String adminPin = '1234';
    return pin == adminPin;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Always block system back button
      onPopInvoked: (didPop) async {
        if (!didPop) {
          // Handle back button press
          await _handleBackNavigation();
        }
      },
      child: Obx(() => _buildCameraView()),
    );
  }

  Widget _buildCameraView() {
    if (!controller.isCameraInitialized.value || controller.cameraController == null) {
      return _buildLoadingView();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildCameraPreview(),
          _buildFaceOverlays(),
          _buildTopInstruction(),
          if (controller.isProcessing.value &&
              controller.recognitionSuccess.value == null)
            _buildProcessingIndicator(),
          if (controller.recognitionSuccess.value != null &&
              !controller.isEarlyCheckoutDialogOpen.value)
            _buildRecognitionResult(),
          if (controller.isRegistrationMode.value &&
              controller.recognitionSuccess.value == null)
            _buildRegistrationButton(),
          _buildBackButton(),
        ],
      ),
    );
  }

  Widget _buildLoadingView() {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          await _handleBackNavigation();
        }
      },
      child: const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text(
                'Initializing camera...',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    final camera = controller.cameraController!;
    final screen = MediaQuery.of(context).size;

    final double previewWidth = screen.width * 0.95;
    final double previewHeight = previewWidth * (4 / 3);

    return Center(
      child: SizedBox(
        width: previewWidth,
        height: previewHeight,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: CameraPreview(camera),
        ),
      ),
    );
  }

  Widget _buildFaceOverlays() {
    return Stack(
      children: [
        CustomPaint(
          painter: FaceOverlayPainter(),
          size: Size.infinite,
        ),
        Obx(() => AnimatedFaceOutline(
          isProcessing: controller.isProcessing.value,
          isSuccess: controller.recognitionSuccess.value,
        )),
      ],
    );
  }

  Widget _buildTopInstruction() {
    return Positioned(
      top: 60,
      left: 20,
      right: 20,
      child: Center(
        child: Text(
          controller.isRegistrationMode.value
              ? "Position your face in the frame"
              : "Scanning for registered faces...",
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            shadows: [
              Shadow(
                color: Colors.black,
                blurRadius: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProcessingIndicator() {
    return Positioned(
      top: 100,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.9),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.5),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              ),
              SizedBox(width: 12),
              Text(
                "Processing...",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecognitionResult() {
    final isSuccess = controller.recognitionSuccess.value ?? false;
    final resultColor = isSuccess ? Colors.green : Colors.red;

    return Positioned(
      bottom: 80,
      left: 16,
      right: 16,
      child: TweenAnimationBuilder(
        duration: const Duration(milliseconds: 400),
        tween: Tween<double>(begin: 0, end: 1),
        builder: (context, double value, child) {
          return Transform.scale(
            scale: value,
            child: Opacity(
              opacity: value,
              child: child,
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                resultColor.withOpacity(0.9),
                resultColor.withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: resultColor.withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSuccess ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: Colors.white,
                size: 36,
              ),
              const SizedBox(height: 4),
              Text(
                isSuccess ? 'Recognized!' : 'Recognition Failed',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (isSuccess && controller.recognizedName.value != null) ...[
                const SizedBox(height: 6),
                Text(
                  controller.recognizedName.value!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (controller.recognizedCode.value != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'ID: ${controller.recognizedCode.value}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
              if (controller.apiMessage.value != null) ...[
                const SizedBox(height: 8),
                Text(
                  controller.apiMessage.value!,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRegistrationButton() {
    return Positioned(
      bottom: 40,
      left: 20,
      right: 20,
      child: Column(
        children: [
          if (controller.selectedEmployeeName.value != null)
            _buildEmployeeNameBadge(),
          const SizedBox(height: 16),
          _buildCaptureButton(),
        ],
      ),
    );
  }

  Widget _buildEmployeeNameBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.person, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            controller.selectedEmployeeName.value!,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaptureButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[600]!, Colors.green[400]!],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: controller.isProcessing.value
            ? null
            : () => controller.captureAndRegister(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.camera_alt, size: 28),
            SizedBox(width: 12),
            Text(
              "Capture & Register",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Positioned(
      top: 50,
      left: 16,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () async {
            await _handleBackNavigation();
          },
        ),
      ),
    );
  }
}