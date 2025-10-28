import 'package:get/get.dart';

class AppController extends GetxController {
  final apiTimer = 3.obs;

  void updateApiTimer(dynamic value) {
    try {
      if (value == null) return;
      final parsedValue = int.tryParse(value.toString()) ?? 3;
      apiTimer.value = parsedValue;
      print('⏱️ Global API timer updated to ${apiTimer.value} seconds');
    } catch (e) {
      print('⚠️ Failed to update API timer: $e');
    }
  }
}
