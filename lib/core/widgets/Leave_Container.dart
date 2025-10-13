import 'package:flutter/material.dart';

import '../../config/app_cards.dart';

class LeaveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double? borderRadius;
  final double? height; // ✅ Added height parameter
  final double? width;
  const LeaveContainer({
    Key? key,
    required this.child,
    this.padding,
    this.color,
    this.borderRadius,
    this.height,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      padding: padding ?? LeaveContainerConfig.defaultPadding,
      decoration: ShapeDecoration(
        color: LeaveContainerConfig.backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? LeaveContainerConfig.defaultBorderRadius),

        ),
      ),
      child: child,
    );
  }

}
