import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FontStyles {
  static TextStyle headingStyle({
    Color color = Colors.black,
    double fontSize = 18,
    FontWeight fontWeight = FontWeight.bold,
  }) {
    return GoogleFonts.plusJakartaSans(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
    );
  }

  static TextStyle subHeadingStyle({
    Color color = Colors.black87,
    double fontSize = 13,
    FontWeight fontWeight = FontWeight.w600,
  }) {
    return GoogleFonts.plusJakartaSans(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
    );
  }

  static TextStyle subTextStyle({
    Color color = Colors.grey,
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
  }) {
    return GoogleFonts.plusJakartaSans(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
    );
  }
}
