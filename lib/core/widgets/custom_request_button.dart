import 'package:flutter/material.dart';

class CustomRequestButton extends StatelessWidget {
  final String status; // "approved", "declined", "requested"
  final double widthFactor;
  final double heightFactor;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final double borderRadius;

  const CustomRequestButton({
    Key? key,
    required this.status,
    this.widthFactor = 0.25,
    this.heightFactor = 0.04,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    this.margin = const EdgeInsets.symmetric(horizontal: 16),
    this.borderRadius = 15.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isApproved = status == 'approved';
    final isDeclined = status == 'declined';

    final bgColor = isApproved
        ? Colors.green
        : isDeclined
        ? Colors.red
        : Colors.orange;

    final text = isApproved
        ? "Approved"
        : isDeclined
        ? "Declined"
        : "Pending";

    final iconPath = isApproved
        ? 'assets/images/approve_icon.png'
        : isDeclined
        ? 'assets/images/decline_icon.png'
        : 'assets/images/decline_icon.png';

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: screenWidth * widthFactor,
      height: screenHeight * heightFactor,
      margin: margin,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Padding(
        padding: padding,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: const TextStyle(fontSize: 12, color: Colors.white),
            ),
            const SizedBox(width: 8),
            Image.asset(
              iconPath,
              height: screenHeight * 0.018,
            ),
          ],
        ),
      ),
    );
  }
}
