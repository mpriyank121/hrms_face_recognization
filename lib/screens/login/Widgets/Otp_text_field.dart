import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class OtpTextFieldController extends GetxController with GetSingleTickerProviderStateMixin {
  late List<TextEditingController> controllers;
  late List<FocusNode> focusNodes;
  late AnimationController animationController;
  late List<Animation<double>> animations;
  final int otpLength = 4;
  final Function(String) onOtpComplete;

  OtpTextFieldController({required this.onOtpComplete});

  @override
  void onInit() {
    super.onInit();
    controllers = List.generate(otpLength, (_) => TextEditingController());
    focusNodes = List.generate(otpLength, (_) => FocusNode());
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    animations = List.generate(
      otpLength,
          (index) => Tween<double>(begin: 1.0, end: 1.2).animate(
        CurvedAnimation(
          parent: animationController,
          curve: Interval(index * 0.1, (index + 1) * 0.1, curve: Curves.easeInOut),
        ),
      ),
    );
  }

  /// Clear all OTP fields and reset focus
  void clearOtp() {
    for (var controller in controllers) {
      controller.clear();
    }
    // Remove focus from all fields
    for (var focusNode in focusNodes) {
      focusNode.unfocus();
    }
    // Reset focus to first field
    if (focusNodes.isNotEmpty) {
      focusNodes[0].requestFocus();
    }
    update(); // Trigger UI update
  }

  /// Get current OTP value
  String getCurrentOtp() {
    return controllers.map((controller) => controller.text).join();
  }

  @override
  void onClose() {
    animationController.dispose();
    for (var controller in controllers) {
      controller.dispose();
    }
    for (var focusNode in focusNodes) {
      focusNode.dispose();
    }
    super.onClose();
  }

  void onOtpChanged(int index, String value) {
    if (value.isNotEmpty) {
      animationController.forward(from: 0.0);
      if (index < otpLength - 1) {
        focusNodes[index + 1].requestFocus();
      }
    }
    String otp = controllers.map((controller) => controller.text).join();
    if (otp.length == otpLength) {
      onOtpComplete(otp);
    }
  }

  void handleKeyEvent(int index, RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.backspace) {
        if (controllers[index].text.isEmpty && index > 0) {
          focusNodes[index - 1].requestFocus();
          controllers[index - 1].clear();
          animationController.forward(from: 0.0);
        }
      }
    }
  }
}

class OtpTextField extends StatelessWidget {
  final Function(String) onOtpComplete;
  final String? tag; // Optional tag to create unique controller instances

  const OtpTextField({
    Key? key,
    required this.onOtpComplete,
    this.tag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use tag to create unique instances or find existing one
    final controller = Get.put(
      OtpTextFieldController(onOtpComplete: onOtpComplete),
      tag: tag,
    );

    double fieldSize = MediaQuery.of(context).size.width * 0.12;
    double fieldHeight = fieldSize * 1.5;

    return GetBuilder<OtpTextFieldController>(
      tag: tag,
      builder: (controller) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(controller.otpLength, (index) {
            return AnimatedBuilder(
              animation: controller.animations[index],
              builder: (context, child) {
                return Transform.scale(
                  scale: controller.animations[index].value,
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 5),
                    width: fieldSize,
                    height: fieldHeight,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: controller.focusNodes[index].hasFocus
                            ? Color(0xFFF25822).withOpacity(0.5)
                            : Colors.white.withOpacity(0.3),
                        width: 1.5,
                      ),
                      boxShadow: controller.focusNodes[index].hasFocus
                          ? [
                        BoxShadow(
                          color: (Color(0xFFF25822)).withOpacity(0.2),
                          blurRadius: 8,
                          spreadRadius: 1,
                        )
                      ]
                          : null,
                    ),
                    child: RawKeyboardListener(
                      focusNode: FocusNode(),
                      onKey: (event) => controller.handleKeyEvent(index, event),
                      child: Center(
                        child: TextField(
                          controller: controller.controllers[index],
                          focusNode: controller.focusNodes[index],
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          style: TextStyle(
                            fontSize: fieldSize * 0.5,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            counterText: '',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                          ),
                          onChanged: (value) => controller.onOtpChanged(index, value),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        );
      },
    );
  }
}