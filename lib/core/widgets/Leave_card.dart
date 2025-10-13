import 'package:flutter/material.dart';

import '../../config/app_cards.dart';

class LeaveCard extends StatelessWidget {
  final String title;
  final String count;
  final double? widthFactor;  // ✅ Custom width factor
  final double? heightFactor; // ✅ Custom height factor
  final Color? backgroundColor;
  final  Color? borderColor;// ✅ Custom background color

  const LeaveCard({
    Key? key,
    required this.title,
    required this.count,
    this.widthFactor,
    this.heightFactor,
    this.backgroundColor,
    this.borderColor,// Optional background color
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widthFactor != null
          ? MediaQuery.of(context).size.width * widthFactor!
          : LeaveCardConfig.defaultWidth(context),
      height: heightFactor != null
          ? MediaQuery.of(context).size.height * heightFactor!
          : LeaveCardConfig.defaultHeight(context),
      padding: LeaveCardConfig.padding(context),
      margin: LeaveCardConfig.margin(context),
      decoration: BoxDecoration(
        color: backgroundColor ?? LeaveCardConfig.backgroundColor,
        borderRadius: BorderRadius.circular(LeaveCardConfig.borderRadius),
        border: Border.all(color: borderColor ?? LeaveCardConfig.borderColor),
      ),

      /// **💡 Center the Row**
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,  // ✅ Centers the Column inside Row
          crossAxisAlignment: CrossAxisAlignment.center,  // ✅ Aligns Column contents
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,  // ✅ Centers text inside Column
              crossAxisAlignment: CrossAxisAlignment.center,  // ✅ Aligns text to center
              children: [
                Text(title, style: LeaveCardConfig.titleStyle),
                Text(count, style: LeaveCardConfig.countStyle),
              ],
            ),
          ],
        ),
      ),
    );

  }
}
