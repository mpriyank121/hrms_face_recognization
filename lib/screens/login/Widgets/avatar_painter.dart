import 'package:flutter/material.dart';

class CircleOverlayPainter extends CustomPainter {
  final bool isFaceInCircle;

  CircleOverlayPainter({this.isFaceInCircle = false});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2.5);
    final radius = size.width * 0.35;

    // Create a path for the entire screen
    final screenPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Create a path for the circle
    final circlePath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius));

    // Subtract circle from screen to get the overlay area
    final overlayPath = Path.combine(
      PathOperation.difference,
      screenPath,
      circlePath,
    );

    // Draw dark overlay outside circle
    final overlayPaint = Paint()
      ..color = Colors.black.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    canvas.drawPath(overlayPath, overlayPaint);

    // Draw circle border with color based on face position
    final borderPaint = Paint()
      ..color = isFaceInCircle
          ? Colors.green.withOpacity(0.8)
          : Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    canvas.drawCircle(center, radius, borderPaint);

    // Add pulsing effect when face is in circle
    if (isFaceInCircle) {
      final glowPaint = Paint()
        ..color = Colors.green.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

      canvas.drawCircle(center, radius, glowPaint);
    }
  }

  @override
  bool shouldRepaint(CircleOverlayPainter oldDelegate) {
    return oldDelegate.isFaceInCircle != isFaceInCircle;
  }
}

/// Animated outline for face detection feedback
class AnimatedFaceOutline extends StatefulWidget {
  final bool isProcessing;
  final bool? isSuccess;
  final bool isFaceInCircle;

  const AnimatedFaceOutline({
    Key? key,
    required this.isProcessing,
    required this.isSuccess,
    this.isFaceInCircle = false,
  }) : super(key: key);

  @override
  State<AnimatedFaceOutline> createState() => _AnimatedFaceOutlineState();
}

class _AnimatedFaceOutlineState extends State<AnimatedFaceOutline>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isFaceInCircle && widget.isSuccess == null) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: FaceOutlinePainter(
            isProcessing: widget.isProcessing,
            isSuccess: widget.isSuccess,
            isFaceInCircle: widget.isFaceInCircle,
            animationValue: _controller.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class FaceOutlinePainter extends CustomPainter {
  final bool isProcessing;
  final bool? isSuccess;
  final bool isFaceInCircle;
  final double animationValue;

  FaceOutlinePainter({
    required this.isProcessing,
    required this.isSuccess,
    required this.isFaceInCircle,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2.5);
    final radius = size.width * 0.35;

    Color circleColor;
    if (isSuccess == true) {
      circleColor = Colors.green;
    } else if (isSuccess == false) {
      circleColor = Colors.red;
    } else if (isFaceInCircle) {
      circleColor = Colors.blue;
    } else {
      return; // Don't draw anything
    }

    // Animated pulsing circle
    final animatedRadius = radius + (10 * animationValue);
    final animatedOpacity = 1.0 - animationValue;

    final paint = Paint()
      ..color = circleColor.withOpacity(animatedOpacity * 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    canvas.drawCircle(center, animatedRadius, paint);

    // Inner solid circle
    final solidPaint = Paint()
      ..color = circleColor.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    canvas.drawCircle(center, radius, solidPaint);
  }

  @override
  bool shouldRepaint(FaceOutlinePainter oldDelegate) {
    return oldDelegate.isProcessing != isProcessing ||
        oldDelegate.isSuccess != isSuccess ||
        oldDelegate.isFaceInCircle != isFaceInCircle ||
        oldDelegate.animationValue != animationValue;
  }
}