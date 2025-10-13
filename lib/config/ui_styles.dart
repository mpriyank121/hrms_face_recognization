import 'package:flutter/material.dart';

class UIStyles {
  static const EdgeInsets dropdownPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 12);

  static final ShapeDecoration dropdownDecoration = ShapeDecoration(
    color: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(25),
      side: BorderSide(width: 1, color: Colors.grey),
    ),
  );

  static const TextStyle dateTextStyle = TextStyle(fontSize: 16, color: Colors.black);

  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Curve animationCurve = Curves.easeInOut;
}
