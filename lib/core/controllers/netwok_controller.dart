import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class NetworkController extends GetxController {
  late StreamSubscription _subscription;

  @override
  void onInit() {
    super.onInit();
    _subscription = Connectivity().onConnectivityChanged.listen((result) {
      if (result == ConnectivityResult.none) {
        Fluttertoast.showToast(msg: "No internet connection");
      } else {
        // Optionally, check for slow connection here
        Fluttertoast.showToast(msg: "Internet connected");
      }
    });
  }

  @override
  void onClose() {
    _subscription.cancel();
    super.onClose();
  }
}