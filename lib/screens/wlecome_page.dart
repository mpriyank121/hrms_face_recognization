import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../config/app_buttons.dart';
import '../config/custom_background.dart';
import '../config/font_style.dart';
import 'login/login_screen.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          CustomBackground(
            imagePath: 'assets/images/bg_image.png',
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Logo/Image at top
                    Image.asset(
                      "assets/images/core_hrx.png",
                      width:  screenWidth * 0.7,
                      height: screenHeight * 0.30,

                    ),

                    SizedBox(height: screenHeight * 0.04),

                    // Info Card Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/images/welcome_image.png',
                        width: screenWidth * 1,
                        fit: BoxFit.cover,
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.03),


                    // Action Buttons

                    OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: PrimaryButtonConfig.color),
                        padding: const EdgeInsets.symmetric(vertical: 14,horizontal: 80),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: Text(
                        "Login",
                        style: FontStyles.subHeadingStyle(
                          color: PrimaryButtonConfig.color,
                          fontSize: 16,
                        ),
                      ),
                    ),


                    SizedBox(height: screenHeight * 0.01),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}