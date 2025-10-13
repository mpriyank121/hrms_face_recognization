import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomCupertinoDialog {
  static void show({
    required BuildContext context,
    required String title,
    required String message,
    String textConfirm = "OK",
    String textCancel = "Cancel",
    Color confirmColor = Colors.red,
    Color cancelColor = Colors.blue,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool barrierDismissible = true,
  }) {
    showCupertinoDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (_) {
        return CupertinoAlertDialog(
          title: Text(title),
          content: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(message),
          ),
          actions: [
            // Cancel Button
            CupertinoDialogAction(
              onPressed: () {
                Get.back(); // Close dialog
                if (onCancel != null) onCancel();
              },
              isDefaultAction: true,
              child: Text(
                textCancel,
                style: TextStyle(color: cancelColor),
              ),
            ),
            // Confirm Button
            CupertinoDialogAction(
              onPressed: () {
                Get.back(); // Close dialog
                if (onConfirm != null) onConfirm();
              },
              isDestructiveAction: true,
              child: Text(
                textConfirm,
                style: TextStyle(color: confirmColor),
              ),
            ),
          ],
        );
      },
    );
  }
}
