import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'package:intl/intl.dart';
import '../../utils/pin_dialog.dart';
import '../controllers/face_detection_controller.dart';
import '../login/Widgets/avatar_painter.dart';

class FaceDetectionView extends StatefulWidget {
  const FaceDetectionView({Key? key}) : super(key: key);

  @override
  State<FaceDetectionView> createState() => _FaceDetectionViewState();
}

class _FaceDetectionViewState extends State<FaceDetectionView> {
  late final FaceDetectionController controller;
  String currentTime = '';
  String currentDate = '';

  @override
  void initState() {
    super.initState();
    controller = Get.find<FaceDetectionController>();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _updateDateTime();
    // Update time every second
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        _updateDateTime();
        return true;
      }
      return false;
    });
  }

  void _updateDateTime() {
    if (mounted) {
      setState(() {
        final now = DateTime.now();
        currentTime = DateFormat('hh:mm:ss a').format(now);
        currentDate = DateFormat('EEEE, MMM dd, yyyy').format(now);
      });
    }
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    controller.closeCamera();
    super.dispose();
  }

  Future<bool> _handleBackNavigation() async {
    if (controller.isRegistrationMode.value) {
      await controller.closeCamera();
      return true;
    }

    final shouldExit = await showPinDialog(context);
    if (shouldExit == true) {
      await controller.closeCamera();
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
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
          _buildBackButton(),
          _buildDateTimeDisplay(),
          _buildTopInstruction(),
          if (controller.isProcessing.value &&
              controller.recognitionSuccess.value == null)
            _buildProcessingIndicator(),
          if (controller.recognitionSuccess.value != null &&
              !controller.isPopupOpen.value)
            _buildRecognitionResult(),
          if (controller.isRegistrationMode.value &&
              controller.recognitionSuccess.value == null)
            _buildRegistrationButton(),
          if (!controller.isRegistrationMode.value)
            _buildWatermark(),
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

  Widget _buildDateTimeDisplay() {
    return Positioned(
      top: 50,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              currentTime,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              currentDate,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopInstruction() {
    return Positioned(
      top: 120,
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
      top: 160,
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
                    'EmpCode: ${controller.recognizedCode.value}',
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

  Widget _buildWatermark() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Powered by ',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                ),
              ),
              // Replace this with your actual logo image
              Image.asset(
                'assets/images/watermark_corehrx.png',
                height: 80,
              ),
            ],
          ),
        ),
      ),
    );
  }
}