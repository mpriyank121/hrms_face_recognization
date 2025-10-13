// custom_dialog.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomDialogs {
  /// Shows a Cupertino-style error dialog
  static void showErrorDialog({
    required String title,
    required String message,
    String? actionText,
    VoidCallback? onPressed,
  }) {
    Get.dialog(
      CupertinoAlertDialog(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.black,
          ),
        ),
        content: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            message,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: CupertinoColors.black,
            ),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: onPressed ?? () => Get.back(),
            child: Text(
              actionText ?? 'OK',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.activeBlue,
              ),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  /// Shows a success dialog
  static void showSuccessDialog({
    required String title,
    required String message,
    String? actionText,
    VoidCallback? onPressed,
  }) {
    Get.dialog(
      CupertinoAlertDialog(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.black,
          ),
        ),
        content: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            message,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: CupertinoColors.black,
            ),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: onPressed ?? () => Get.back(),
            child: Text(
              actionText ?? 'OK',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.activeBlue,
              ),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  /// Shows a confirmation dialog with two actions
  static void showConfirmationDialog({
    required String title,
    required String message,
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
    String confirmText = 'Yes',
    String cancelText = 'Cancel',
  }) {
    Get.dialog(
      CupertinoAlertDialog(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.black,
          ),
        ),
        content: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            message,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: CupertinoColors.black,
            ),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: onCancel ?? () => Get.back(),
            child: Text(
              cancelText,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w400,
                color: CupertinoColors.activeBlue,
              ),
            ),
          ),
          CupertinoDialogAction(
            onPressed: () {
              Get.back();
              onConfirm();
            },
            isDestructiveAction: true,
            child: Text(
              confirmText,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.destructiveRed,
              ),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
}