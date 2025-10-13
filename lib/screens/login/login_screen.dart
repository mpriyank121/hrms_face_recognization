import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../config/custom_background.dart';
import '../../config/style.dart';
import '../../core/widgets/primary_button.dart';
import 'controller/login_controller.dart';
import 'otp_screen.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final AuthController authController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false, // removes default back button
          centerTitle: false, // aligns title to the start
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/core_hrx.png',height: 200,width: 200,)
            ],
          ),
        ),

        backgroundColor: Colors.white,
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            CustomBackground(
              imagePath: 'assets/images/background_image.png',
            ),
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05,
                  vertical: screenHeight * 0.01,
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Text(
                          //   'HR Management App',
                          //   style: fontStyles.commonTextStyle,
                          // ),
                          Text(
                            'Enter your mobile number to get started',
                            style: fontStyles.commonTextStyle,
                          ),
                          SizedBox(height: screenHeight * 0.015),
                          TextField(
                            controller: authController.phoneController,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(10),
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            style: fontStyles.headingStyle.copyWith(fontSize: 16),
                            decoration: InputDecoration(
                              prefixIcon: Padding(
                                padding: const EdgeInsets.only(left: 12, right: 8),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '+91',
                                      style: fontStyles.headingStyle.copyWith(fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      width: 1,
                                      height: 24,
                                      color: Colors.grey.shade400,
                                    ),
                                  ],
                                ),
                              ),
                              prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                              hintText: 'Enter mobile number',
                              hintStyle: fontStyles.commonTextStyle.copyWith(color: Colors.grey.shade500),
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(color: Colors.deepOrange, width: 1.8),
                              ),
                            ),
                          ),

                        ],
                      ),
                    ),
                    Obx(() => PrimaryButton(
                        onPressed: authController.isLoading.value
                            ? null
                            : () async {
                          await authController.sendOtpToUser(context);
                          if (authController.isOtpSent.value) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OtpPage(
                                  phone: authController.phoneController.text.trim(),
                                ),
                              ),
                            );
                          }
                        },
                        icon: authController.isLoading.value
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                            : SvgPicture.asset("assets/images/Arrow_Circle_Right.svg"),
                        text: authController.isLoading.value ? 'Sending OTP...' : 'Continue',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
