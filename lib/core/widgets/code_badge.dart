import 'package:flutter/material.dart';

class CodeBadge extends StatelessWidget {
  final String? empCode;
  final Color bgColor;
  final int? count;

  const CodeBadge({
    Key? key,
    this.empCode,
    this.bgColor = Colors.deepOrange,
    this.count,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String displayText = empCode ?? count?.toString() ?? '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        displayText,
        style: const TextStyle(
          fontSize: 10,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
