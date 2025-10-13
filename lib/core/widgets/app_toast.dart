import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppToast {
  static void show({
    required String message,
    bool isError = false,
    Duration duration = const Duration(seconds: 2),
  }) {
    Get.closeAllSnackbars(); // optional: avoids stacking
    Get.rawSnackbar(
      messageText: Text(
        message,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isError ? Colors.red.shade700 : Colors.black87,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      borderRadius: 8,
      duration: duration,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      animationDuration: const Duration(milliseconds: 300),
    );
  }
}
