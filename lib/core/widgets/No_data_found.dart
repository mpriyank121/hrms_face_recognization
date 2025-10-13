import 'package:flutter/material.dart';

class NoDataWidget extends StatelessWidget {
  final String message;
  final String imagePath;
  final double imageHeight;
  final double imageWidth;
  final TextStyle? textStyle;

  const NoDataWidget({
    Key? key,
    required this.message,
    this.imagePath = "assets/images/Error_image.png",
    this.imageHeight = 150,
    this.imageWidth = 150,
    this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            imagePath,
            height: imageHeight,
            width: imageWidth,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 5),
          Text(
            message,
            textAlign: TextAlign.center,
            style: textStyle ??
                const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
          ),
        ],
      ),
    );
  }
}
