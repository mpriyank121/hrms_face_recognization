import 'package:flutter/material.dart';
import 'dart:math' as math;

class FaceOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final overlayPaint = Paint()
      ..color = Colors.black.withOpacity(0.65)
      ..style = PaintingStyle.fill;

    final path = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final center = Offset(size.width / 2, size.height / 2);
    // Adjusted for 3:4 aspect ratio - using height as reference for better fit
    final radius = size.height * 0.2;

    final circlePath = Path()..addOval(Rect.fromCircle(center: center, radius: radius));

    final cutoutPath = Path.combine(PathOperation.difference, path, circlePath);
    canvas.drawPath(cutoutPath, overlayPaint);

    // Add a soft glow ring
    final glowPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 10);
    canvas.drawCircle(center, radius, glowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 🔹 Animated circular outline painter
class AnimatedFaceOutline extends StatefulWidget {
  final bool isProcessing;
  final bool? isSuccess;

  const AnimatedFaceOutline({
    super.key,
    this.isProcessing = false,
    this.isSuccess,
  });

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
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: FaceOutlinePainter(
        isProcessing: widget.isProcessing,
        isSuccess: widget.isSuccess,
        rotationValue: _controller.value,
      ),
    );
  }
}

// 🔹 Painter for circular animated face outline with modern border design
class FaceOutlinePainter extends CustomPainter {
  final bool isProcessing;
  final bool? isSuccess;
  final double rotationValue;

  FaceOutlinePainter({
    this.isProcessing = false,
    this.isSuccess,
    this.rotationValue = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = size.height * 0.2;

    // Choose colors by state
    Color primaryColor;
    Color secondaryColor;
    Color accentColor;

    if (isSuccess == true) {
      primaryColor = const Color(0xFF00FF88);
      secondaryColor = Colors.green;
      accentColor = const Color(0xFF00FFAA);
    } else if (isSuccess == false) {
      primaryColor = Colors.redAccent;
      secondaryColor = Colors.red;
      accentColor = const Color(0xFFFF5555);
    } else if (isProcessing) {
      primaryColor = const Color(0xFF00E5FF);
      secondaryColor = const Color(0xFF00FF88);
      accentColor = const Color(0xFF0099FF);
    } else {
      primaryColor = Colors.white54;
      secondaryColor = Colors.white24;
      accentColor = Colors.white38;
    }

    // Draw modern border design with gradient effect
    _drawModernBorder(canvas, center, baseRadius, primaryColor, accentColor, rotationValue);

    // Draw corner brackets (inner frame)
    _drawCornerBrackets(canvas, center, baseRadius * 0.85, primaryColor);

    // Draw multiple animated rings
    _drawAnimatedRing(canvas, center, baseRadius * 1.0, primaryColor, secondaryColor, rotationValue, 3.0);
    _drawAnimatedRing(canvas, center, baseRadius * 1.15, primaryColor.withOpacity(0.6), secondaryColor.withOpacity(0.6), rotationValue * 0.7, 2.5);
    _drawAnimatedRing(canvas, center, baseRadius * 2.3, primaryColor.withOpacity(0.4), secondaryColor.withOpacity(0.4), rotationValue * 0.5, 2.0);

    // Draw scanning dots on the rings
    _drawScanningDots(canvas, center, baseRadius * 1.0, primaryColor, rotationValue);
    _drawScanningDots(canvas, center, baseRadius * 1.15, primaryColor.withOpacity(0.7), rotationValue * 0.7);
    _drawScanningDots(canvas, center, baseRadius * 1.3, primaryColor.withOpacity(0.5), rotationValue * 0.5);
  }

  void _drawModernBorder(Canvas canvas, Offset center, double radius, Color primaryColor, Color accentColor, double progress) {
    // Outer glowing ring
    final outerGlowPaint = Paint()
      ..color = primaryColor.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
    canvas.drawCircle(center, radius * 1.05, outerGlowPaint);

    // Main border with gradient effect (simulated with multiple circles)
    final gradientSteps = 3;
    for (int i = 0; i < gradientSteps; i++) {
      final opacity = 0.8 - (i * 0.2);
      final borderPaint = Paint()
        ..color = primaryColor.withOpacity(opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0 - (i * 0.5);
      canvas.drawCircle(center, radius + (i * 1.5), borderPaint);
    }

    // Animated highlight segments
    final highlightPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    final segments = 4;
    for (int i = 0; i < segments; i++) {
      final startAngle = (i * 2 * math.pi / segments) + (progress * 2 * math.pi);
      final sweepAngle = math.pi / 8;

      // Gradient effect using shader
      final rect = Rect.fromCircle(center: center, radius: radius);
      highlightPaint.shader = LinearGradient(
        colors: [
          accentColor.withOpacity(0.9),
          primaryColor.withOpacity(0.3),
        ],
      ).createShader(rect);

      canvas.drawArc(rect, startAngle, sweepAngle, false, highlightPaint);
    }

    // Inner shadow effect
    final innerShadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..maskFilter = const MaskFilter.blur(BlurStyle.inner, 8);
    canvas.drawCircle(center, radius * 0.98, innerShadowPaint);

    // Decorative corner dots
    _drawCornerDots(canvas, center, radius, primaryColor, progress);
  }

  void _drawCornerDots(Canvas canvas, Offset center, double radius, Color color, double progress) {
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final glowDotPaint = Paint()
      ..color = color.withOpacity(0.4)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final positions = [0, math.pi / 2, math.pi, 3 * math.pi / 2];

    for (var angle in positions) {
      final pulseEffect = 1 + (0.2 * math.sin(progress * 2 * math.pi + angle));
      final dx = center.dx + radius * 1.02 * math.cos(angle);
      final dy = center.dy + radius * 1.02 * math.sin(angle);

      canvas.drawCircle(Offset(dx, dy), 4 * pulseEffect, glowDotPaint);
      canvas.drawCircle(Offset(dx, dy), 2.5, dotPaint);
    }
  }

  void _drawCornerBrackets(Canvas canvas, Offset center, double radius, Color color) {
    final bracketPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final bracketLength = radius * 0.25;

    // Calculate corner positions
    final corners = [
      {'angle': -math.pi / 4, 'rotations': [0, math.pi / 2]}, // Top-left
      {'angle': math.pi / 4, 'rotations': [-math.pi / 2, 0]}, // Top-right
      {'angle': 3 * math.pi / 4, 'rotations': [math.pi, -math.pi / 2]}, // Bottom-right
      {'angle': -3 * math.pi / 4, 'rotations': [math.pi / 2, math.pi]}, // Bottom-left
    ];

    for (var corner in corners) {
      final angle = corner['angle'] as double;
      final rotations = corner['rotations'] as List<double>;

      final cornerX = center.dx + radius * math.cos(angle);
      final cornerY = center.dy + radius * math.sin(angle);
      final cornerPos = Offset(cornerX, cornerY);

      for (var rotation in rotations) {
        final endX = cornerX + bracketLength * math.cos(angle + rotation);
        final endY = cornerY + bracketLength * math.sin(angle + rotation);
        canvas.drawLine(cornerPos, Offset(endX, endY), bracketPaint);
      }
    }
  }

  void _drawAnimatedRing(Canvas canvas, Offset center, double radius, Color startColor, Color endColor, double progress, double strokeWidth) {
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw multiple arc segments around the circle
    final segments = 8;
    final gapAngle = math.pi / 24; // Small gap between segments

    for (int i = 0; i < segments; i++) {
      final startAngle = (i * 2 * math.pi / segments) + (progress * 2 * math.pi);
      final sweepAngle = (2 * math.pi / segments) - gapAngle;

      // Alternate colors
      final segmentColor = i.isEven ? startColor : endColor;
      arcPaint.color = segmentColor;

      final rect = Rect.fromCircle(center: center, radius: radius);
      canvas.drawArc(rect, startAngle, sweepAngle, false, arcPaint);
    }

    // Add glow effect
    final glowPaint = Paint()
      ..color = startColor.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 4
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(center, radius, glowPaint);
  }

  void _drawScanningDots(Canvas canvas, Offset center, double radius, Color color, double progress) {
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw 2-3 dots at specific positions on the ring
    final dotPositions = [0, 2, 5]; // Positions on the circle

    for (var pos in dotPositions) {
      final angle = (progress * 2 * math.pi) + (pos * math.pi / 4);
      final dx = center.dx + radius * math.cos(angle);
      final dy = center.dy + radius * math.sin(angle);

      canvas.drawCircle(Offset(dx, dy), 3.5, dotPaint);

      // Add glow to dots
      final glowDotPaint = Paint()
        ..color = color.withOpacity(0.4)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(Offset(dx, dy), 5, glowDotPaint);
    }
  }

  @override
  bool shouldRepaint(FaceOutlinePainter oldDelegate) =>
      oldDelegate.isProcessing != isProcessing ||
          oldDelegate.isSuccess != isSuccess ||
          oldDelegate.rotationValue != rotationValue;
}