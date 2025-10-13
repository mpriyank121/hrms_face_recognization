// lib/core/utils/shared_pref_helper.dart
import 'package:shared_preferences/shared_preferences.dart';


class SharedPrefHelper {
  static const String _phoneKey = 'user_phone';
  static const String companyId = 'company_id';
  static const String _userRoleKey = 'user_role';
  static const String _empId = 'id';

  static Future<void> savePhone(String phone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_phoneKey, phone);
  }

  static Future<String?> getPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_phoneKey);
  }

  static Future<void> clearPhone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_phoneKey);
  }
  static Future<void> saveCompanyId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(companyId, id); // Use the constant as key, id as value
  }
  static Future<String?> getCompanyId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(companyId);
  }

  static Future<void> clearCompanyId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(companyId);
  }

  static Future<void> saveUserRoleId(String roleId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userRoleKey, roleId);
  }

  // Get user role ID
  static Future<String?> getUserRoleId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userRoleKey);
  }

  // Optionally, clear user role ID
  static Future<void> clearUserRoleId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userRoleKey);
  }
  static Future<void> saveEmpId(String empId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_empId, empId); // Use the constant as key, id as value
  }
  static Future<String?> getEmpId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_empId);
  }

  static Future<void> clearEmpId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_empId);
  }
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }


}

