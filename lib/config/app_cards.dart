import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class TileConfig {
  static const Color backgroundColor = Colors.white24;
  static const Color borderColor = AppColors.border;
  static final TextStyle headingStyle = AppTextStyles.heading;
  static final TextStyle subTextStyle = AppTextStyles.subText;
  static const EdgeInsets padding = EdgeInsets.all(10);
}

class WelcomeCardConfig {
  static const Color backgroundColor = AppColors.primary;
  static const double borderRadius = 8.0;
  static final TextStyle welcomeText = AppTextStyles.textStyle(color: AppColors.textPrimary);
  static final TextStyle nameText = AppTextStyles.textStyle(fontSize: 24, fontWeight: FontWeight.w500);
  static final TextStyle roleText = AppTextStyles.textStyle(fontWeight: FontWeight.w500);
}

class BottomCardConfig {
  static const Color borderColor = Colors.grey; // Customize Border Color
  static const double borderWidth = 1.0;
  static const Color backgroundColor = AppColors.backgroundLight;
  static const double borderRadius = 8.0;
  static const double separatorWidthFactor = 0.003;
  static const Color separatorColor = Colors.grey;
  static const double separatorHeightFactor = 0.06;
  static final TextStyle commonTextStyle = AppTextStyles.subText;
}

class LeaveCardConfig {
  static const double borderRadius = 12.0;
  static const Color backgroundColor = Color(0xFFECF8F4);
  static const Color borderColor = AppColors.primary;
  static const EdgeInsets defaultPadding = EdgeInsets.all(6.0);
  static const EdgeInsets defaultMargin = EdgeInsets.all(8.0);
  static final TextStyle titleStyle = AppTextStyles.textStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey);
  static final TextStyle countStyle = AppTextStyles.textStyle(fontSize: 14, color: Colors.grey[700]!);
  static EdgeInsets padding(BuildContext context) {
    return const EdgeInsets.symmetric(vertical: 2, horizontal: 2);
  }

  static EdgeInsets margin(BuildContext context) {
    return const EdgeInsets.symmetric(vertical: 1, horizontal: 4);
  }

  static double defaultWidth(BuildContext context) {
    return MediaQuery.of(context).size.width * 0.29; // Default to 40% of screen width
  }

  static double defaultHeight(BuildContext context) {
    return MediaQuery.of(context).size.height * 0.06;  // Default fixed height
  }

}

class OtpTextFieldConfig {
  static const Color background = AppColors.textSecondary;
  static const double widthFactor = 0.1;
  static const double heightFactor = 0.06;
  static const double fontSizeFactor = 0.022;
  static const Color textColor = Colors.white;
  static const Color borderColor = Colors.transparent;
}
class LeaveContainerConfig {

  static const EdgeInsets defaultPadding = EdgeInsets.only(left: 12,right: 12);
  static const double defaultBorderRadius = 8.0;
  static const Color defaultColor = Colors.white; // Equivalent to Colors.grey[200]
  static const Color backgroundColor = Color(0xFFEEEEEE);
}

