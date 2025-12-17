import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:audioplayers/audioplayers.dart';
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
  final AudioPlayer _audioPlayer = AudioPlayer();

  Timer? _clearTimer;
  bool? _lastSuccessState;
  String? _lastMessage;
  int _resultCount = 0;

  @override
  void dispose() {
    _clearTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playSound(bool isSuccess) async {
    try {
      await _audioPlayer.stop();
      if (isSuccess) {
        await _audioPlayer.play(AssetSource('sounds/checkin_success.mp3'));
      } else {
        await _audioPlayer.play(AssetSource('sounds/checkin_error.mp3'));
      }
    } catch (e) {
      print('Error playing sound: $e');
    }
  }

  void _startClearTimer() {
    _clearTimer?.cancel();

    // Notify controller that result is being displayed
    widget.controller.onResultDisplayed();

    _clearTimer = Timer(Duration(seconds: appController.apiTimer.value), () {
      if (mounted) {
        widget.controller.recognitionSuccess.value = null;
        widget.controller.recognizedName.value = null;
        widget.controller.recognizedCode.value = null;
        widget.controller.apiMessage.value = '';
        _lastSuccessState = null;
        _lastMessage = null;

        // Notify controller that result is cleared
        widget.controller.onResultCleared();
        print('🎭 Result cleared - Resuming in 1 second...');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSuccess = widget.controller.recognitionSuccess.value;
      final apiMessage = widget.controller.apiMessage.value;
      final recognizedName = widget.controller.recognizedName.value;

      // Detect if this is a NEW result
      final currentMessage = '$isSuccess-$recognizedName-$apiMessage';

      if (isSuccess != null && currentMessage != _lastMessage) {
        _lastMessage = currentMessage;
        _lastSuccessState = isSuccess;
        _resultCount++;
        print('🆕 New result detected (#$_resultCount): Success=$isSuccess, Name=$recognizedName');

        // Play sound based on success/failure
        _playSound(isSuccess);

        _startClearTimer();
      }

      // Clear tracking when result is cleared
      if (isSuccess == null) {
        _lastMessage = null;
        _lastSuccessState = null;
      }

      final resultColor = (isSuccess ?? false) ? Colors.green : Colors.red;

      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: TweenAnimationBuilder(
            key: ValueKey(_resultCount),
            duration: const Duration(milliseconds: 600),
            tween: Tween<double>(begin: 0, end: 1),
            builder: (context, double value, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: child,
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    resultColor.withOpacity(0.95),
                    resultColor.withOpacity(0.85),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: resultColor.withOpacity(0.4),
                    blurRadius: 32,
                    offset: const Offset(0, 12),
                    spreadRadius: 4,
                  ),
                  BoxShadow(
                    color: resultColor.withOpacity(0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Status Icon
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.15),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            (isSuccess ?? false)
                                ? Icons.check_circle_rounded
                                : Icons.cancel_rounded,
                            color: Colors.white,
                            size: 48,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Status Text
                        Text(
                          (isSuccess ?? false) ? 'Recognized!' : 'Recognition Failed',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Employee Details Container
                        if ((isSuccess ?? false) && recognizedName != null)
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.15),
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  recognizedName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.2,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                if (widget.controller.recognizedCode.value != null) ...[
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.2),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      'EmpCode: ${widget.controller.recognizedCode.value}',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          )
                        else if (!(isSuccess ?? false))
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.15),
                                width: 1.5,
                              ),
                            ),
                            child: const Text(
                              'Please try again',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),

                        // API Message
                        if (widget.controller.apiMessage.value.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.12),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              widget.controller.apiMessage.value,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}