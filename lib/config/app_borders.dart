import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppBorders {
  static const double radius = 15.0;
  static const double borderWidth = 1.0;
  static const BorderSide borderSide = BorderSide(color: AppColors.border, width: borderWidth);
  static const BoxDecoration bottomBorder = BoxDecoration(border: Border(bottom: borderSide));
}
