import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../config/app_buttons.dart';
import '../../config/app_text_styles.dart';

class PrimaryButtonController extends GetxController {
  final RxBool isLoading = false.obs;

  Future<void> handlePress({
    Future<void> Function()? onPressedAsync,
    Function()? onPressed
  }) async {
    if (isLoading.value) return;

    if (onPressedAsync != null) {
      isLoading.value = true;
      try {
        await onPressedAsync();
      } catch (e) {
        rethrow;
      } finally {
        isLoading.value = false;
      }
    } else if (onPressed != null) {
      // Check if onPressed returns a Future
      final result = onPressed();
      if (result is Future) {
        isLoading.value = true;
        try {
          await result;
        } catch (e) {
          rethrow;
        } finally {
          isLoading.value = false;
        }
      }
      // If it's not a Future, it's a sync function, so no loading needed
    }
  }
}

class PrimaryButton extends StatelessWidget {
  final String text;
  final Function()? onPressed;
  final Future<void> Function()? onPressedAsync;
  final double? widthFactor;
  final double? heightFactor;
  final Color? buttonColor;
  final Color? textColor;
  final Widget? icon;
  final Widget? loadingIcon;
  final double? textSize;

  const PrimaryButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.onPressedAsync,
    this.widthFactor,
    this.heightFactor,
    this.buttonColor,
    this.textColor,
    this.icon,
    this.loadingIcon,
    this.textSize
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Create a unique tag for this button instance
    final String controllerTag = '${text}_${hashCode}';
    final controller = Get.put(PrimaryButtonController(), tag: controllerTag);

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return InkWell(
      onTap: () => controller.handlePress(onPressedAsync: onPressedAsync, onPressed: onPressed),
      borderRadius: BorderRadius.circular(PrimaryButtonConfig.borderRadius),
      splashColor: Colors.white.withOpacity(0.3),
      child: Padding(
        padding: PrimaryButtonConfig.padding,
        child: Obx(() => AnimatedContainer(
          duration: PrimaryButtonConfig.animationDuration,
          width: screenWidth * (widthFactor ?? PrimaryButtonConfig.widthFactor),
          height: screenHeight * (heightFactor ?? PrimaryButtonConfig.heightFactor),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: controller.isLoading.value
                ? (buttonColor ?? PrimaryButtonConfig.color).withOpacity(0.6)
                : buttonColor ?? PrimaryButtonConfig.color,
            borderRadius: BorderRadius.circular(PrimaryButtonConfig.borderRadius),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                controller.isLoading.value ? 'Loading...' : text,
                style: AppTextStyles.buttonText.copyWith(
                  color: textColor ?? Colors.white,
                  fontSize: textSize ?? AppTextStyles.buttonText.fontSize,
                ),
              ),
              const SizedBox(width: 8),
              if (controller.isLoading.value) ...[
                loadingIcon ??
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          textColor ?? Colors.white,
                        ),
                      ),
                    ),
                const SizedBox(width: 8),
              ] else if (icon != null) ...[
                icon!,
                const SizedBox(width: 8),
              ],
            ],
          ),
        )),
      ),
    );
  }
}