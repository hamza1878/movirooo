import 'package:flutter/material.dart';

class MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Map background
    final bgPaint = Paint()..color = const Color(0xFFE8EFD8);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Water
    final waterPaint = Paint()..color = const Color(0xFFB8D8E8);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.78, size.height * 0.22),
        width: size.width * 0.7,
        height: size.height * 0.45,
      ),
      waterPaint,
    );

    // Road grid
    final roadPaint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    for (int i = 0; i < 7; i++) {
      path.moveTo(0, size.height * (0.1 + i * 0.13));
      path.lineTo(size.width, size.height * (0.08 + i * 0.14));
    }
    for (int i = 0; i < 5; i++) {
      path.moveTo(size.width * (0.1 + i * 0.2), 0);
      path.lineTo(size.width * (0.05 + i * 0.22), size.height);
    }
    canvas.drawPath(path, roadPaint);

    // Route line
    final routePaint = Paint()
      ..color = const Color(0xFF3B4FC8)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final routePath = Path();
    routePath.moveTo(size.width * 0.18, size.height * 0.12);
    routePath.cubicTo(
      size.width * 0.38, size.height * 0.28,
      size.width * 0.58, size.height * 0.52,
      size.width * 0.84, size.height * 0.80,
    );
    canvas.drawPath(routePath, routePaint);

    // Start marker
    canvas.drawCircle(
      Offset(size.width * 0.18, size.height * 0.12),
      7,
      Paint()..color = const Color(0xFF3B4FC8),
    );
    canvas.drawCircle(
      Offset(size.width * 0.18, size.height * 0.12),
      4,
      Paint()..color = Colors.white,
    );

    // End marker
    canvas.drawCircle(
      Offset(size.width * 0.84, size.height * 0.80),
      7,
      Paint()..color = const Color(0xFFA855F7),
    );
    canvas.drawCircle(
      Offset(size.width * 0.84, size.height * 0.80),
      4,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}