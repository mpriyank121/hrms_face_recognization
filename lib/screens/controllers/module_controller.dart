import 'package:get/get.dart';

import '../face_detection/models/organization_modules.dart';
import '../face_detection/service/module_service.dart';

class ModuleController extends GetxController {
  var isLoading = false.obs;
  var showModules = <OrganizationModule>[].obs;
  var alreadyModules = <OrganizationModule>[].obs;
  var modules = <OrganizationModule>[].obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadOrganizationModules();
  }

  Future<void> loadOrganizationModules() async {
    try {
      isLoading(true);
      errorMessage('');

      // Call service which now returns a map with both arrays
      final result = await ModuleService.fetchOrganizationModules();

      showModules.assignAll(result['showModules'] ?? []);
      alreadyModules.assignAll(result['alreadyModules'] ?? []);

      // For backward compatibility, combine both
      modules.assignAll([...showModules, ...alreadyModules]);

    } catch (e) {
      errorMessage(e.toString());
      print("⚠️ Error loading modules: $e");
    } finally {
      isLoading(false);
    }
  }

  bool hasShowModuleById(int moduleId) {
    return showModules.any((m) => m.id == moduleId);
  }

  /// Check module exists by ID in already_modules
  bool hasAlreadyModuleById(int moduleId) {
    return alreadyModules.any((m) => m.id == moduleId);
  }

  /// Get module details by ID from show_modules
  OrganizationModule? getShowModuleById(int moduleId) {
    try {
      return showModules.firstWhere((m) => m.id == moduleId);
    } catch (e) {
      return null;
    }
  }

  /// Get module details by ID from already_modules
  OrganizationModule? getAlreadyModuleById(int moduleId) {
    try {
      return alreadyModules.firstWhere((m) => m.id == moduleId);
    } catch (e) {
      return null;
    }
  }

  /// Check module exists by route in show_modules
  bool hasShowModuleByRoute(String route) {
    return showModules.any((m) => m.moduleRoute == route);
  }

  /// Check module exists by route in already_modules
  bool hasAlreadyModuleByRoute(String route) {
    return alreadyModules.any((m) => m.moduleRoute == route);
  }

  /// Get module by route from show_modules
  OrganizationModule? getShowModuleByRoute(String route) {
    try {
      return showModules.firstWhere((m) => m.moduleRoute == route);
    } catch (e) {
      return null;
    }
  }

  /// Get module by route from already_modules
  OrganizationModule? getAlreadyModuleByRoute(String route) {
    try {
      return alreadyModules.firstWhere((m) => m.moduleRoute == route);
    } catch (e) {
      return null;
    }
  }

  /// Check if module exists in either list by ID
  bool hasModuleById(int moduleId) {
    return hasShowModuleById(moduleId) || hasAlreadyModuleById(moduleId);
  }

  /// Get module from either list by ID
  OrganizationModule? getModuleById(int moduleId) {
    return getShowModuleById(moduleId) ?? getAlreadyModuleById(moduleId);
  }

  /// Check if module exists in either list by route
  bool hasModuleByRoute(String route) {
    return hasShowModuleByRoute(route) || hasAlreadyModuleByRoute(route);
  }

  /// Get module from either list by route
  OrganizationModule? getModuleByRoute(String route) {
    return getShowModuleByRoute(route) ?? getAlreadyModuleByRoute(route);
  }
}