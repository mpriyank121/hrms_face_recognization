import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF3CAB88);
  static const Color secondary = Color(0xFFF25922);
  static const Color border = Color(0xFFE6E6E6);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.grey;
  static const Color backgroundLight = Colors.white;
}
class LeaveRequestColor {
  // Primary orange color - change this to modify the color throughout the app
  static const Color primaryOrange = Color(0xFFF25822); // You can change this hex value

  // Different shades of the primary orange for various uses
  static Color get lightOrange => primaryOrange.withOpacity(0.3);
  static Color get mediumOrange => primaryOrange.withOpacity(0.7);
  static Color get darkOrange => primaryOrange.withOpacity(0.7);

// Alternative orange shades (uncomment to use different orange tones)
// static const Color primaryOrange = Color(0xFFFF6B35); // Red-orange
// static const Color primaryOrange = Color(0xFFFF9500); // iOS orange
// static const Color primaryOrange = Color(0xFFFF7043); // Material orange
// static const Color primaryOrange = Color(0xFFFFA726); // Lighter orange
}