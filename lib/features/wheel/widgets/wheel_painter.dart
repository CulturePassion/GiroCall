import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/app_colors.dart';
import '../../../shared/models/contact.dart';

/// CustomPainter that draws a colorful segmented wheel.
class WheelPainter extends CustomPainter {
  final List<Contact> contacts;
  final double rotation;

  WheelPainter({
    required this.contacts,
    required this.rotation,
  });

  static const List<Color> _sliceColors = [
    AppColors.primaryTeal,
    AppColors.accentCoral,
    AppColors.secondaryBlue,
    Color(0xFF8B5CF6),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFFEC4899),
    Color(0xFF06B6D4),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (contacts.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;
    final sliceAngle = 2 * pi / contacts.length;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation * pi / 180);
    canvas.translate(-center.dx, -center.dy);

    for (var i = 0; i < contacts.length; i++) {
      final paint = Paint()
        ..color = _sliceColors[i % _sliceColors.length]
        ..style = PaintingStyle.fill;

      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..arcFromCenter(
          center: center,
          radius: radius,
          startAngle: i * sliceAngle,
          sweepAngle: sliceAngle,
        )
        ..close();

      canvas.drawPath(path, paint);

      // Draw white separator lines.
      final linePaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 2;
      final lineEnd = Offset(
        center.dx + radius * cos(i * sliceAngle),
        center.dy + radius * sin(i * sliceAngle),
      );
      canvas.drawLine(center, lineEnd, linePaint);

      // Draw initial letter.
      final textAngle = i * sliceAngle + sliceAngle / 2;
      final textOffset = Offset(
        center.dx + radius * 0.65 * cos(textAngle),
        center.dy + radius * 0.65 * sin(textAngle),
      );

      final initial =
          contacts[i].name.isNotEmpty ? contacts[i].name[0].toUpperCase() : '?';

      final textPainter = TextPainter(
        text: TextSpan(
          text: initial,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        textOffset.translate(-textPainter.width / 2, -textPainter.height / 2),
      );
    }

    canvas.restore();

    // Center circle.
    final centerPaint = Paint()
      ..color = AppColors.surface
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.12, centerPaint);

    final borderPaint = Paint()
      ..color = AppColors.primaryTeal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawCircle(center, radius * 0.12, borderPaint);

    // Phone icon in center.
    final textPainter = TextPainter(
      text: const TextSpan(
        text: '📞',
        style: TextStyle(fontSize: 22),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      center.translate(-textPainter.width / 2, -textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant WheelPainter oldDelegate) {
    return oldDelegate.rotation != rotation || oldDelegate.contacts != contacts;
  }
}

extension on Path {
  void arcFromCenter({
    required Offset center,
    required double radius,
    required double startAngle,
    required double sweepAngle,
  }) {
    arcTo(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
    );
  }
}
