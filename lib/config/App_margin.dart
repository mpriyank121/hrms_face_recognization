import 'package:flutter/material.dart';

class AppMargin extends StatelessWidget {
  final Widget child;

  const AppMargin({required this.child});

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0), // Set margin as per your need
      child: child,
    ));
  }
}
