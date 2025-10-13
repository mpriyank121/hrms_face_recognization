import 'dart:async';
import 'package:flutter/material.dart';
import '../../config/app_buttons.dart';
import 'package:get/get.dart';

class ResendButtonController extends GetxController {
  final RxInt seconds = ResendButtonConfig.timerDuration.obs;
  final RxBool isButtonEnabled = false.obs;
  Timer? _timer;
  final VoidCallback onResend;

  ResendButtonController({required this.onResend});

  @override
  void onInit() {
    super.onInit();
    _startTimer();
  }

  void _startTimer() {
    isButtonEnabled.value = false;
    seconds.value = ResendButtonConfig.timerDuration;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (seconds.value > 0) {
        seconds.value--;
      } else {
        _timer?.cancel();
        isButtonEnabled.value = true;
      }
    });
  }

  void handleResend() {
    onResend();
    _startTimer();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}

class ResendButton extends StatelessWidget {
  final VoidCallback onResend;
  final double? widthFactor;
  final double? heightFactor;

  const ResendButton({
    super.key,
    required this.onResend,
    this.heightFactor,
    this.widthFactor,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ResendButtonController(onResend: onResend));

    return Obx(() => GestureDetector(
      onTap: controller.isButtonEnabled.value
          ? controller.handleResend
          : null,
      child: Container(
        padding: ResendButtonConfig.padding,
        decoration: BoxDecoration(
          border: Border.all(color: ResendButtonConfig.borderColor),
          borderRadius:
          BorderRadius.circular(ResendButtonConfig.borderRadius),
        ),
        child: RichText(
          text: TextSpan(
            style: TextStyle(
                fontSize: 12, color: ResendButtonConfig.textColor),
            children: [
              const TextSpan(text: "Resend code "),
              TextSpan(
                text: controller.isButtonEnabled.value
                    ? ""
                    : " : 0:${controller.seconds.value}",
                style: TextStyle(
                  color: ResendButtonConfig.timerColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}

