import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../controllers/app_controller.dart';
import '../controllers/face_detection_controller.dart';

class RecognitionResultWidget extends StatefulWidget {
  final FaceDetectionController controller;


  const RecognitionResultWidget({Key? key, required this.controller}) : super(key: key);

  @override
  State<RecognitionResultWidget> createState() => _RecognitionResultWidgetState();
}

class _RecognitionResultWidgetState extends State<RecognitionResultWidget> {
  final appController = Get.find<AppController>();

  Timer? _clearTimer;
  bool? _lastSuccessState;
  String? _lastMessage;
  int _resultCount = 0; // Track number of results to detect changes

  @override
  void dispose() {
    _clearTimer?.cancel();
    super.dispose();
  }

  void _startClearTimer() {
    // Cancel any existing timer
    _clearTimer?.cancel();

    // Start new 10-second timer
    _clearTimer = Timer( Duration(seconds: appController.apiTimer.value), () {
      if (mounted) {
        widget.controller.recognitionSuccess.value = null;
        widget.controller.recognizedName.value = null;
        widget.controller.recognizedCode.value = null;
        widget.controller.apiMessage.value = '';
        _lastSuccessState = null;
        _lastMessage = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSuccess = widget.controller.recognitionSuccess.value;
      final apiMessage = widget.controller.apiMessage.value;
      final recognizedName = widget.controller.recognizedName.value;

      // Detect if this is a NEW result by checking if any key value changed
      final currentMessage = '$isSuccess-$recognizedName-$apiMessage';

      if (isSuccess != null && currentMessage != _lastMessage) {
        _lastMessage = currentMessage;
        _lastSuccessState = isSuccess;
        _resultCount++;
        print('🆕 New result detected (#$_resultCount): Success=$isSuccess, Name=$recognizedName');
        _startClearTimer();
      }

      // Clear tracking when result is cleared
      if (isSuccess == null) {
        _lastMessage = null;
        _lastSuccessState = null;
      }

      final resultColor = (isSuccess ?? false) ? Colors.green : Colors.red;

      return Positioned(
        bottom: 80,
        left: 16,
        right: 16,
        child: TweenAnimationBuilder(
          key: ValueKey(_resultCount), // Force animation restart on each new result
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
                  (isSuccess ?? false) ? Icons.check_circle_rounded : Icons.cancel_rounded,
                  color: Colors.white,
                  size: 36,
                ),
                const SizedBox(height: 4),
                Text(
                  (isSuccess ?? false) ? 'Recognized!' : 'Recognition Failed',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if ((isSuccess ?? false) && recognizedName != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    recognizedName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (widget.controller.recognizedCode.value != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'EmpCode: ${widget.controller.recognizedCode.value}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
                if (widget.controller.apiMessage.value.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    widget.controller.apiMessage.value,
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
    });
  }
}