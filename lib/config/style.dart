import 'package:flutter/material.dart';

class fontStyles {
  static const TextStyle headingStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Colors.black,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Colors.white,
  );

  static const TextStyle subTextStyle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: Color(0xFF949494),
  );

  static const TextStyle commonTextStyle = TextStyle(
    color: Color(0xFF666666),
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1,
  );

  static const TextStyle normalText = TextStyle(
    color: Color(0xFF212121),
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.60,
  );

  static const whiteText = TextStyle(
    color: Colors.white,
    fontSize: 14,
  );

  static const TextStyle subHeadingStyle = TextStyle(
    color: Color(0xFF000000),
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.6, // 160% = 1.6
    letterSpacing: 0.2,
  );
}

// CustomRow
class CustomRow extends StatelessWidget {
  final List<Widget> items;

  const CustomRow({required this.items, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Evenly distributes columns
      children: items
          .map((item) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: item,
      ))
          .toList(),
    );
  }
}

// LeaveCard / AppStyles
class AppStyles {
  static const TextStyle textStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.black,
  );
}

class InvertedTopCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    // Start at top-left corner
    path.moveTo(0, 40);

    // Control point below the top edge (creates the dip in the center)
    final controlPoint = Offset(size.width / 2, 100);
    final endPoint = Offset(size.width, 40);

    // Create the inverted (concave) curve at the top
    path.quadraticBezierTo(
      controlPoint.dx,
      controlPoint.dy,
      endPoint.dx,
      endPoint.dy,
    );

    // Draw the rest of the rectangle
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class TripleOrangeWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = Color(0xFFF36634);
    final paint1 = Paint()..color =  Color(0xFFF4774A);
    final paint2 = Paint()..color = Color(0xFFFF8F66); // Middle medium orange
    final paint3 = Paint()..color =  Color(0xFFF9B79F); // Bottom light orange
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(rect, bgPaint);

    // --- Bottom Layer (light orange) ---
    final path3 = Path();
    path3.moveTo(0, size.height * 0.4);
    path3.quadraticBezierTo(
      size.width * 0.25, size.height * 0.55,
      size.width * 0.5, size.height * 0.5,
    );
    path3.quadraticBezierTo(
      size.width * 0.75, size.height * 0.45,
      size.width, size.height * 0.6,
    );
    path3.lineTo(size.width, size.height);
    path3.lineTo(0, size.height);
    path3.close();

    // --- Middle Layer (medium orange) ---
    final path2 = Path();
    path2.moveTo(0, size.height * 0.25);
    path2.quadraticBezierTo(
      size.width * 0.25, size.height * 0.4,
      size.width * 0.5, size.height * 0.35,
    );
    path2.quadraticBezierTo(
      size.width * 0.75, size.height * 0.3,
      size.width, size.height * 0.45,
    );
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();

    // --- Top Layer (dark orange) ---
    final path1 = Path();
    path1.moveTo(0, 0);
    path1.lineTo(0, size.height * 0.2);
    path1.quadraticBezierTo(
      size.width * 0.25, size.height * 0.35,
      size.width * 0.5, size.height * 0.3,
    );
    path1.quadraticBezierTo(
      size.width * 0.75, size.height * 0.25,
      size.width, size.height * 0.4,
    );
    path1.lineTo(size.width, 0);
    path1.close();

    // Draw in reverse order (bottom to top)
    canvas.drawPath(path3, paint3); // light orange
    canvas.drawPath(path2, paint2); // medium orange
    canvas.drawPath(path1, paint1); // dark orange
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}



