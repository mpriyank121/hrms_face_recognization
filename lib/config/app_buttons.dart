import 'package:flutter/material.dart';
import 'app_colors.dart';

class ButtonConfig {
  static const double borderRadius = 8.0;
  static const double widthFactor = 0.9;
  static const double heightFactor = 0.07;
  static const EdgeInsets padding = EdgeInsets.symmetric(horizontal: 10, vertical: 5);
  static const Duration animationDuration = Duration(milliseconds: 300);
}
class PrimaryButtonConfig {
  static const Color color = AppColors.secondary;
  static const double borderRadius = 8.0;
  static const double widthFactor = 0.9;
  static const double heightFactor = 0.06;
  static const EdgeInsets padding = EdgeInsets.symmetric(horizontal: 5, vertical: 5);
  static const Duration animationDuration = Duration(milliseconds: 300);
}

class ResendButtonConfig {
  static const int timerDuration = 30; // Timer starts from 30 seconds
  static const Color borderColor = Colors.orange;
  static const Color textColor = Colors.grey;
  static const Color timerColor = Colors.orange;
  static const double borderRadius = 8.0;
  static const EdgeInsets padding = EdgeInsets.symmetric(horizontal: 25, vertical: 15);
}
class AppConfig {
  // Default Colors for Buttons
  static const Color defaultButtonColor = Colors.grey;
  static final ButtonStyle reasonButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: defaultButtonColor,
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
    minimumSize: const Size(30, 22),
    textStyle: const TextStyle(fontSize: 9),
  );
}