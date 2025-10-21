import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hrms_face_recognization/core/encryption/encryption_helper.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../constants/api_constants.dart';
import 'dio_client.dart';

class CheckAppVersionService {
  /// Check the current app version from the backend.
  static Future<Map<String, dynamic>> checkAppVersion() async {
    try {
      final dio = DioClient().client;

      final packageInfo = await PackageInfo.fromPlatform();
      final appVersion = packageInfo.version; // e.g. "1.0.2"
      // 🔐 Prepare encrypted payload
      final encryptedType = EncryptionHelper.encryptString('FaceAppVersionCheck');

      final formData = FormData.fromMap({
        'type': encryptedType,
        'version': EncryptionHelper.encryptString(appVersion), // Replace with actual encrypted version if needed
      });

      if (kDebugMode) {
        formData.fields.forEach((field) {
          debugPrint('🗝️ ${field.key}: ${field.value}');
        });
      }

      // 🌐 Send API request
      final response = await dio.post(ApiConstants.face, data: formData);
      final data = response.data;

      if (kDebugMode) {
        debugPrint("📥 Check App Version Response: $data");
      }

      // 🧩 Return parsed result
      return {
        'success': true,
        'found': data['found'] ?? false,
        'check': data['check'] ?? 0,
        'mandatory': data['mandatory'] ?? '0',
        'description': data['description'] ?? '',
        'app_link': data['app_link'] ?? '',
        'version': data['version'] ?? '',
      };
    } catch (e) {
      if (kDebugMode) {
        debugPrint("❌ Check App Version Error: $e");
      }

      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
}
