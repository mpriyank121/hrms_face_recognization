import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

enum ToastPosition { top, bottom }

class CustomToast {
  static void show({
    required BuildContext context,
    required String message,
    bool isError = false,
    Duration duration = const Duration(seconds: 2),
    ToastPosition position = ToastPosition.bottom,
    String? actionText,
    VoidCallback? onActionPressed,
  }) {
    _showCupertinoDialog(
      context: context,
      message: message,
      isError: isError,
      actionText: actionText,
      onActionPressed: onActionPressed,
    );
  }

  static void _showCupertinoDialog({
    required BuildContext context,
    required String message,
    required bool isError,
    String? actionText,
    VoidCallback? onActionPressed,
  }) {
    try {
      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            content: Text(message),
            actions: [
              if (actionText != null && onActionPressed != null)
                CupertinoDialogAction(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onActionPressed();
                  },
                  child: Text(actionText),
                ),
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      // ✅ fallback to Get.snackbar
      Get.snackbar(
        '',
        message,
        backgroundColor: isError
            ? Colors.red.shade700
            : Colors.green.shade700,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(20),
        borderRadius: 8,
        titleText: const SizedBox.shrink(), // removes title space
      );
    }
  }

  static void showMessage({
    required BuildContext context,
    required String message,
    bool isError = false,
    Duration duration = const Duration(seconds: 2),
    ToastPosition position = ToastPosition.bottom,
    String? actionText,
    VoidCallback? onActionPressed,
  }) {
    show(
      context: context,
      message: message,
      isError: isError,
      duration: duration,
      position: position,
      actionText: actionText,
      onActionPressed: onActionPressed,
    );
  }

  static void showError({
    required BuildContext context,
    required String message,
    String? actionText,
    VoidCallback? onActionPressed,
  }) {
    show(
      context: context,
      message: message,
      isError: true,
      actionText: actionText,
      onActionPressed: onActionPressed,
    );
  }

  static void showSuccess({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 2),
    ToastPosition position = ToastPosition.bottom,
    String? actionText,
    VoidCallback? onActionPressed,
  }) {
    show(
      context: context,
      message: message,
      isError: false,
      duration: duration,
      position: position,
      actionText: actionText,
      onActionPressed: onActionPressed,
    );
  }
}
