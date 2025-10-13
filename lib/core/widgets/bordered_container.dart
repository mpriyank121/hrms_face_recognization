// lib/widgets/bordered_container.dart

import 'package:flutter/material.dart';

class BorderedContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final EdgeInsets margin;

  const BorderedContainer({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(4),
    this.margin = const EdgeInsets.symmetric(vertical: 0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.deepOrange.withOpacity(0.2),
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }
}
