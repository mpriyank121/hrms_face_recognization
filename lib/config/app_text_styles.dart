import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  static TextStyle textStyle({
    Color color = AppColors.textPrimary,
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
  }) {
    return GoogleFonts.plusJakartaSans(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
    );
  }

  static TextStyle get heading => textStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get subText => textStyle(
    color: AppColors.textSecondary,
  );

  static TextStyle get buttonText => textStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
  );
}

class GreyTextStyles {
  static TextStyle small({
    Color color = Colors.grey,
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
  }) {
    return TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
    );
  }

  static TextStyle medium({
    Color color = Colors.grey,
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w500,
  }) {
    return TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
    );
  }

  static TextStyle large({
    Color color = Colors.grey,
    double fontSize = 18,
    FontWeight fontWeight = FontWeight.w600,
  }) {
    return TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
    );
  }
}
