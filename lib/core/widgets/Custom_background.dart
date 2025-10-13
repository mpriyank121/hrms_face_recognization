import 'package:flutter/material.dart';

class CustomBackground extends StatelessWidget {
  final String imagePath;
  final double topOffsetFactor;
  final double rightOffsetFactor;
  final double widthFactor;
  final double heightFactor;

  const CustomBackground({
    Key? key,
    required this.imagePath,
    this.topOffsetFactor = 0,
    this.rightOffsetFactor = 0.2,
    this.widthFactor = 1.2,
    this.heightFactor = 0.7,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Positioned(
      top: screenHeight * topOffsetFactor,
      right: -screenWidth * rightOffsetFactor,
      child: Image.asset(
        imagePath,
        width: screenWidth * widthFactor,
        height: screenHeight * heightFactor,
        fit: BoxFit.cover,
      ),
    );
  }
}
