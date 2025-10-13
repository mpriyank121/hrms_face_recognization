import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

String getPlatform() {
  if (kIsWeb) return "web";
  if (Platform.isAndroid) return "android";
  if (Platform.isIOS) return "ios";
  if (Platform.isWindows) return "windows";
  if (Platform.isLinux) return "linux";
  if (Platform.isMacOS) return "macos";
  return "unknown";
}
