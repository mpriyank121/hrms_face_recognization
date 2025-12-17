import 'package:dio/dio.dart';
import '../../../constants/api_constants.dart';
import '../../../core/encryption/encryption_helper.dart';
import '../../../utils/dio_client.dart';
import '../../../utils/shared_pref_helper.dart';
import '../models/organization_modules.dart';

class ModuleService {
  static Future<List<OrganizationModule>> fetchModules({

    Map<String, dynamic>? headers,
  }) async {
    final dio = DioClient().client;
    if (headers != null) {
      DioClient().setHeaders();
    }

    final formData = FormData.fromMap({
      'type': EncryptionHelper.encryptString('getAllModules'),
    });

    try {
      final response = await dio.post(ApiConstants.home, data: formData);
      final jsonResponse = response.data;
      print("🔹 Organization Modules Response: $jsonResponse");

      if (jsonResponse['status'] == true) {
        final modulesData = jsonResponse['data']['modules'] ?? [];
        return modulesData.map<OrganizationModule>(
              (e) => OrganizationModule.fromJson(e),
        ).toList();
      } else {
        throw (jsonResponse['message'] ?? 'Failed to fetch modules');
      }
    } catch (e) {
      throw ('❌ Error fetching organization modules: $e');
    }
  }
  static Future<Map<String, dynamic>> fetchOrganizationModules({

    Map<String, dynamic>? headers,
  }) async {
    final companyId = await SharedPrefHelper.getCompanyId();
    final dio = DioClient().client;
    if (headers != null) {
      DioClient().setHeaders();
    }

    final formData = FormData.fromMap({
      'type': EncryptionHelper.encryptString('getOrganizationModulesDynamic'),
      'c_id': companyId,
    });

    try {
      final response = await dio.post(ApiConstants.home, data: formData);
      final jsonResponse = response.data;
      print("🔹 Organization Modules Response: $jsonResponse");

      if (jsonResponse['status'] == true) {
        final showModulesData = jsonResponse['data']['show_modules'] ?? [];
        final alreadyModulesData = jsonResponse['data']['already_modules'] ?? [];

        final showModules = showModulesData.map<OrganizationModule>(
              (e) => OrganizationModule.fromJson(e),
        ).toList();

        final alreadyModules = alreadyModulesData.map<OrganizationModule>(
              (e) => OrganizationModule.fromJson(e),
        ).toList();
        return {
          'showModules': showModules,
          'alreadyModules': alreadyModules,
        };

      } else {
        throw (jsonResponse['message'] ?? 'Failed to fetch modules');
      }
    } catch (e) {
      throw ('❌ Error fetching organization modules: $e');
    }
  }
}
