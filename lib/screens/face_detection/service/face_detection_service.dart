import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:get/get_core/src/get_main.dart';
import 'package:hrms_face_recognization/constants/api_constants.dart';
import 'package:dio/dio.dart';
import '../../../core/encryption/encryption_helper.dart';
import '../../../utils/dio_client.dart';
import '../../../utils/location_helper.dart';
import '../../../utils/shared_pref_helper.dart';
import '../../controllers/app_controller.dart';

class FaceRecognitionService {
  static Future<Map<String, dynamic>> registerFace({
    required String empId,
    required File imageFile,
  }) async {
    final companyId = await SharedPrefHelper.getCompanyId();
    final encryptedType = EncryptionHelper.encryptString('registerFace');
    final encryptedEmpId = EncryptionHelper.encryptString(empId);

    final dio = DioClient().client;

    // Prepare form-data
    final formData = FormData.fromMap({
      'type': encryptedType,
      'org_id': companyId,
      'emp_id': encryptedEmpId,
      'image': await MultipartFile.fromFile(
        imageFile.path,
        filename: 'face_${DateTime.now().millisecondsSinceEpoch}.jpg',
      ),
    });
    formData.fields.forEach((field) {
      print('🗝️ ${field.key}: ${field.value}');
    });
    try {
      final response = await dio.post(ApiConstants.face, data: formData);
      final data = response.data;

      if (kDebugMode) {
        debugPrint("📥 Register Face Response: $data");
      }

      return {
        'success': data['status'] ?? false,
        'message': data['message'] ?? '',
        'data': data['data'] ?? {},
      };
    } catch (e) {
      if (kDebugMode) debugPrint("❌ Register Face Error: $e");
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Recognize a face
  static Future<Map<String, dynamic>> recognizeFace({
    String? earlyCheckout,
    String? empCode,
    required File imageFile,
  }) async {
    final encryptedType = EncryptionHelper.encryptString('recognizeFace');
    final companyId = await SharedPrefHelper.getCompanyId();
    final latitude = await LocationHelper.getLatitude();
    final longitude = await LocationHelper.getLongitude();
    final city = await LocationHelper.getCity();
    final pincode = await LocationHelper.getPincode();
    final address = await LocationHelper.getAddress();

    final dio = DioClient().client;

    // Prepare form-data safely
    final formDataMap = {
      'type': encryptedType,
      'org_id': companyId,
      'image': await MultipartFile.fromFile(
        imageFile.path,
        filename: 'face_${DateTime.now().millisecondsSinceEpoch}.jpg',
      ),
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'pincode': pincode,
      'city': city,
    };

    if (earlyCheckout != null) {
      formDataMap['early_check_out'] = earlyCheckout;
    }

    if (empCode != null && empCode.isNotEmpty) {
      formDataMap['emp_code'] = EncryptionHelper.encryptString(empCode);
    }

    final formData = FormData.fromMap(formDataMap);
    print('---📤 Sending FormData to Backend ---');
    formDataMap.forEach((key, value) {
      if (value is MultipartFile) {
        print('$key: [File] ${value.filename}');
      } else {
        print('$key: $value');
      }
    });
    try {
      final response = await dio.post(ApiConstants.face, data: formData);
      final data = response.data;

      if (kDebugMode) debugPrint("📥 Recognize Face Response: $data");

      // ✅ Handle both Map and List types for `data['data']`
      final rawData = data['data'];
      Map<String, dynamic>? dataMap;
      if (rawData is Map<String, dynamic>) {
        dataMap = rawData;
      }

      // ✅ Determine if recognized
      final isRecognized = data['recognized'] == true ||
          data['emp_id'] != null ||
          (dataMap?['emp_id'] != null) ||
          data['status'] == true;

      return {
        'success': data['status'] ?? false,
        'recognized': isRecognized,
        'emp_code': dataMap?['emp_code'] ?? data['emp_code'] ?? '',
        'emp_name': dataMap?['emp_name'] ?? data['emp_name'] ?? '',
        'emp_id': data['emp_id'] ?? dataMap?['emp_id'],
        'message': data['message'] ?? '',
        'early_checkout_status': data['early_checkout_status'],
        'show_popup': data['show_popup'] == true, // ✅ ADD THIS

      };
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint("❌ Recognize Face Error: $e");
        debugPrint("📍 StackTrace: $stackTrace");
      }
      return {'success': false, 'recognized': false, 'message': e.toString()};
    }
  }

  /// Get employee details
  static Future<Map<String, dynamic>> fetchEmployees({
    DateTime? startDate,
    DateTime? endDate,
    Map<String, dynamic>? headers,
  }) async {
    final companyId = await SharedPrefHelper.getCompanyId();
    final dio = DioClient().client;

    if (headers != null) {
      DioClient().setHeaders();
    }
    final encryptedType = EncryptionHelper.encryptString('getEmpFaceRegistry');
    final formData = FormData.fromMap({
      'type': encryptedType,
      'c_id': companyId,
    });
    formData.fields.forEach((element) {
      print('  ${element.key}: ${element.value}');
    });

    try {
      final response = await dio.post(ApiConstants.home, data: formData);
      print('[DEBUG] Response Status: ${response.statusCode}');
      print('[DEBUG] Response Data: ${response.data}');
      final data = response.data['data'];
      final appController = Get.isRegistered<AppController>()
          ? Get.find<AppController>()
          : Get.put(AppController());
      appController.updateApiTimer(response.data['timer']);


      return response.data;

    } catch (e) {
      print('[ERROR] fetchEmployees : $e');
      rethrow;
    }
  }
  static Future<bool> deleteFace({
    required String empId,
  }) async {
    try {
      final encryptedType = EncryptionHelper.encryptString('deleteFace');
      final encryptedEmpId = EncryptionHelper.encryptString(empId);
      final companyId = await SharedPrefHelper.getCompanyId();


      final formData = FormData.fromMap({
        'type': encryptedType,
        'emp_id': encryptedEmpId,
        'org_id': companyId,
      });

      debugPrint("📤 Sending deleteFace request...");
      debugPrint("🧩 FormData: ${formData.fields}");

      final response = await Dio().post(
        ApiConstants.face,
        data: formData,
        options: Options(responseType: ResponseType.json),
      );

      // Handle PHP JSON string responses
      final data = response.data is String
          ? jsonDecode(response.data)
          : response.data;

      debugPrint("📥 Raw response: $data");

      if (data['status'] == true) {
        debugPrint("✅ Face deleted successfully for $empId.");
        return true;
      } else {
        debugPrint("⚠️ Failed to delete face: ${data['message']}");
        return false;
      }
    } catch (e, stack) {
      debugPrint("❌ Error deleting face: $e");
      debugPrint("📚 Stack trace: $stack");
      return false;
    }
  }

}



