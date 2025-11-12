import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../auth_controller.dart';
import '../../../core/widgets/custom_toast.dart';
import '../../../utils/shared_pref_helper.dart';
import '../../face_detection/face_detection_screen.dart';

class AuthController extends GetxController {
  final phoneController = TextEditingController();
  final otpController = TextEditingController();
  var isLoading = false.obs;

  final isOtpSent = false.obs;
  final isPhoneVerified = false.obs;

  /// Clear OTP and reset verification state
  void clearOtpAndResetState() {
    otpController.clear();
    isOtpSent.value = false;
    isPhoneVerified.value = false;
  }

  /// Send OTP
  Future<void> sendOtpToUser(BuildContext context) async {
    clearOtpAndResetState();
    final phone = phoneController.text.trim();

    // ✅ Validate phone number
    if (phone.isEmpty || phone.length != 10 || !RegExp(r'^[0-9]+$').hasMatch(phone)) {
      CustomToast.showMessage(
        context: context,
        message: "Please enter a valid 10-digit phone number",
        isError: true,
      );
      return;
    }

    try {
      isLoading.value = true;

      // Clear previous OTP before sending new one
      otpController.clear();

      final response = await OrganizationLoginAuth.sendOtp(phone);
      print('OTP Response: $response');

      if (response['status'] == true) {
        final userType = response['userType']?.toString().toLowerCase();

        // ✅ Allow login only if usertype is "organization"
        if (userType == 'organization') {
          isOtpSent.value = true;
          isPhoneVerified.value = false;
        } else {
          CustomToast.showMessage(
            context: context,
            message: "You are not allowed to login with this account.",
            isError: true,
          );
        }
      } else {
        CustomToast.showMessage(
          context: context,
          message: response['message'] ?? "Failed to send OTP",
          isError: true,
        );
      }
    } catch (e) {
      CustomToast.showMessage(
        context: context,
        message: e.toString(),
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }


  /// Verify OTP
  Future<void> verifyUserOtp(BuildContext context) async {
    final phone = phoneController.text.trim();
    final otp = otpController.text.trim();

    debugPrint('🔍 Verifying OTP for phone: $phone with OTP: $otp');

    if (otp.isEmpty) {
      CustomToast.showMessage(
        context: context,
        message: "Please enter OTP",
        isError: true,
      );
      return;
    }

    try {
      isLoading.value = true;
      debugPrint('⏳ Sending OTP verification request...');

      final response = await OrganizationLoginAuth.verifyOtp(phone, otp);
      debugPrint('✅ OTP verification response: $response');

      // ✅ Only continue if API confirms success
      if (response['success'] != true) {
        CustomToast.showMessage(
          context: context,
          message: response['message'] ?? "Invalid OTP",
          isError: true,
        );
        return;
      }

      // ✅ OTP Verified
      isPhoneVerified.value = true;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await SharedPrefHelper.savePhone(phone);

      final data = response['data'] ?? {};

      // ✅ company_id
      String? companyId = data['company_id']?.toString();
      if (companyId != null && companyId.isNotEmpty) {
        await SharedPrefHelper.saveCompanyId(companyId);
        debugPrint('🏢 company_id retrieved and saved: $companyId');
      } else {
        companyId = prefs.getString('company_id');
        if (companyId != null && companyId.isNotEmpty) {
          debugPrint('📦 company_id loaded from SharedPreferences fallback: $companyId');
        } else {
          debugPrint('⚠️ No company_id found.');
        }
      }

      // ✅ user_role
      final userRole = data['user_role']?.toString();
      if (userRole != null) {
        await SharedPrefHelper.saveUserRoleId(userRole);
        debugPrint("✅ Saved user role: $userRole");
      }

      // ✅ emp_id
      final empId = data['emp_id']?.toString();
      if (empId != null) {
        await SharedPrefHelper.saveEmpId(empId);
        debugPrint("✅ Saved user empId: $empId");
      }

      // ✅ Navigate only when company_id exists
      if (companyId != null && companyId.isNotEmpty) {
        CustomToast.showMessage(
          context: context,
          message: "OTP Verified Successfully!",
          isError: false,
        );

      Get.offAll(() =>  FaceDetectionScreen(orgId: '',));
      } else {
        CustomToast.showMessage(
          context: context,
          message: "Company ID missing, cannot proceed.",
          isError: true,
        );
      }
    } catch (e) {
      CustomToast.showMessage(
        context: context,
        message: e.toString(),
        isError: true,
      );
    } finally {
      isLoading.value = false;
      debugPrint('✅ Finished OTP verification process.');
    }
  }


  @override
  void onClose() {
    phoneController.dispose();
    otpController.dispose();
    super.onClose();
  }
}