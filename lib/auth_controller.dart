import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart' hide FormData;
import 'package:get/get_core/src/get_main.dart';
import 'package:hrms_face_recognization/screens/wlecome_page.dart';
import 'package:hrms_face_recognization/utils/dio_client.dart';
import 'package:hrms_face_recognization/utils/encryption_helper.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/api_constants.dart';


class OrganizationRegisterAuth {
  static const String _baseUrl = ApiConstants.apis;

  /// Send OTP to a phone number (already encoded)
  static Future<Map<String, dynamic>> sendOtp(String Phone) async {
    final dio = DioClient().client;
    final formData = FormData.fromMap({
      'type': EncryptionHelper.encryptString("sendOtp"),
      'phone': EncryptionHelper.encryptString(Phone),
    });
    final response = await dio.post(_baseUrl, data: formData);
    final jsonResponse = response.data;
    if (jsonResponse['status'] == true) {
      return jsonResponse;
    } else {
      throw ('${jsonResponse['message'] ?? 'Unknown error'}');
    }
  }

  /// Verify OTP with phone and otp (all encoded if required)
  static Future<Map<String, dynamic>> verifyOtp(String phone, String otp) async {
    final dio = DioClient().client;
    final formData = FormData.fromMap({
      'type': EncryptionHelper.encryptString("otpVerification"),
      'phone': EncryptionHelper.encryptString(phone),
      'otp': EncryptionHelper.encryptString(otp),
    });
    final response = await dio.post(_baseUrl, data: formData);
    final jsonResponse = response.data;
    print("cvcb${jsonResponse}");
    if (jsonResponse['success'] == true) {
      Get.to(WelcomePage());

      return jsonResponse;

    } else {
      throw ('Verify OTP failed:  ${jsonResponse['message'] ?? 'Unknown error'}');
    }
  }
}

class OrganizationLoginAuth {
  static const String _baseUrl = ApiConstants.users;

  static Future<Map<String, dynamic>> sendOtp(String Phone) async {
    final dio = DioClient().client;
    final formData = FormData.fromMap({
      'type': EncryptionHelper.encryptString("loginUser"),
      'phone': EncryptionHelper.encryptString(Phone),
    });
    final response = await dio.post(_baseUrl, data: formData);
    final jsonResponse = response.data;
    print("${jsonResponse}");
    if (jsonResponse['status'] == true) {
      return jsonResponse;
    } else {
      throw ('${jsonResponse['message'] ?? 'Unknown error'}');
    }
  }

  static Future<Map<String, dynamic>> verifyOtp(String phone, String otp) async {
    debugPrint("🔐 Starting OTP verification...");
    debugPrint("📱 Original Phone: $phone");
    debugPrint("🔢 Original OTP: $otp");

    final encryptedPhone = EncryptionHelper.encryptString(phone);
    final encryptedOtp = EncryptionHelper.encryptString(otp);

    debugPrint("🔐 Encrypted Phone: $encryptedPhone");
    debugPrint("🔐 Encrypted OTP: $encryptedOtp");

    final dio = DioClient().client;
    final formData = FormData.fromMap({
      'type': EncryptionHelper.encryptString("userOtpVerify"), // Encrypted 'verifyOtp'
      'phone': encryptedPhone,
      'otp': encryptedOtp,
    });

    debugPrint("🌐 Sending request to $_baseUrl with fields:");
    formData.fields.forEach((field) => debugPrint("  ${field.key}: ${field.value}"));

    try {
      final response = await dio.post(_baseUrl, data: formData);
      final jsonResponse = response.data;

      debugPrint("📩 Raw Response Body: $jsonResponse");

      if (response.statusCode == 200) {
        debugPrint("✅ Parsed JSON Response: $jsonResponse");

        if (jsonResponse['success'] == true) {

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('phone', phone);

          debugPrint("✅ Phone number saved to SharedPreferences: $phone");
          await _setupHeadersAfterLogin(jsonResponse['data']);
          return {
            'success': true,
            'message': jsonResponse['message'] ?? 'OTP verified',
            'data': jsonResponse['data']
          };
        } else {
          final errorMsg = jsonResponse['message'] ?? 'OTP verification failed';
          debugPrint("❌ API returned an error: $errorMsg");

          return {
            'success': false,
            'message': errorMsg,
          };
        }
      } else {
        debugPrint("❌ Server Error: HTTP ${response.statusCode}");
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': '${e.toString()}',
      };
    }
  }
  static Future<void> _setupHeadersAfterLogin(Map<String, dynamic>? userData) async {
    try {
      final dioClient = DioClient();

      // Get FCM token
      // final fcmToken = await getFcmToken();
      // if (fcmToken == null) {
      //   debugPrint("⚠️ FCM token is null");
      //   return;
      // }

      final employeeId = userData?['emp_id'] ?? '';
      final organizationId = userData?['company_id'] ;

      debugPrint("🔑 Setting up headers:");
      //debugPrint("  FCM Token: ${fcmToken}...");
      debugPrint("  Employee ID: $employeeId");
      debugPrint("  Organization ID: $organizationId");

      // Set headers with auth and FCM data
      await dioClient.setHeaders(
        //fcmId: fcmToken,
        employeeId: employeeId.toString(),
        organizationId: organizationId.toString(),
      );

      debugPrint("✅ Headers set successfully");

    } catch (e) {
      debugPrint("❌ Error setting up headers: $e");
    }
  }
}
