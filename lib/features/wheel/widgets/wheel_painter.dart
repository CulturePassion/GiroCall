import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../core/app_colors.dart';
import '../../../shared/models/contact.dart';

/// Colorful glass-style segmented wheel using brand tile palette.
class WheelPainter extends CustomPainter {
  final List<Contact> contacts;
  final double rotation;

  WheelPainter({
    required this.contacts,
    required this.rotation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (contacts.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 4;
    final sliceAngle = 2 * pi / contacts.length;

    _drawOuterGlow(canvas, center, radius);
    _drawOuterRing(canvas, center, radius);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation * pi / 180);
    canvas.translate(-center.dx, -center.dy);

    for (var i = 0; i < contacts.length; i++) {
      final baseColor =
          AppColors.wheelSliceColors[i % AppColors.wheelSliceColors.length];
      final start = i * sliceAngle;

      _drawSlice(canvas, center, radius, start, sliceAngle, baseColor);
      _drawSliceSeparator(canvas, center, radius, start);

      final textAngle = start + sliceAngle / 2;
      _drawSliceLabel(
        canvas,
        center,
        radius,
        textAngle,
        contacts[i].name.isNotEmpty ? contacts[i].name[0].toUpperCase() : '?',
      );
    }

    canvas.restore();

    _drawGlassHub(canvas, center, radius * 0.16);
    _drawPointer(canvas, center, radius);
  }

  void _drawOuterGlow(Canvas canvas, Offset center, double radius) {
    final glow = Paint()
      ..shader = ui.Gradient.radial(
        center,
        radius + 20,
        [
          AppColors.paletteTeal.withValues(alpha: 0.15),
          Colors.transparent,
        ],
      );
    canvas.drawCircle(center, radius + 20, glow);
  }

  void _drawOuterRing(Canvas canvas, Offset center, double radius) {
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = Colors.white.withValues(alpha: 0.7);
    canvas.drawCircle(center, radius + 2, ring);

    final shadow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..color = AppColors.paletteTeal.withValues(alpha: 0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(center, radius + 4, shadow);
  }

  void _drawSlice(
    Canvas canvas,
    Offset center,
    double radius,
    double start,
    double sweep,
    Color base,
  ) {
    final rect = Rect.fromCircle(center: center, radius: radius);
    final lighter = Color.lerp(base, Colors.white, 0.22)!;
    final darker = Color.lerp(base, Colors.black, 0.12)!;

    final paint = Paint()
      ..shader = ui.Gradient.sweep(
        center,
        [lighter, base, darker, lighter],
        [0, 0.35, 0.7, 1],
        TileMode.clamp,
        start,
        start + sweep,
      );

    final path = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(rect, start, sweep, false)
      ..close();

    canvas.drawPath(path, paint);
  }

  void _drawSliceSeparator(
      Canvas canvas, Offset center, double radius, double angle) {
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    final end = Offset(
      center.dx + radius * cos(angle),
      center.dy + radius * sin(angle),
    );
    canvas.drawLine(center, end, linePaint);
  }

  void _drawSliceLabel(
    Canvas canvas,
    Offset center,
    double radius,
    double angle,
    String initial,
  ) {
    final offset = Offset(
      center.dx + radius * 0.68 * cos(angle),
      center.dy + radius * 0.68 * sin(angle),
    );

    final textPainter = TextPainter(
      text: TextSpan(
        text: initial,
        style: TextStyle(
          color: Colors.white,
          fontSize: radius * 0.11,
          fontWeight: FontWeight.w700,
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 4,
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      offset.translate(-textPainter.width / 2, -textPainter.height / 2),
    );
  }

  void _drawGlassHub(Canvas canvas, Offset center, double hubRadius) {
    final hubShadow = Paint()
      ..color = AppColors.paletteTeal.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(center, hubRadius + 4, hubShadow);

    final hubFill = Paint()
      ..shader = ui.Gradient.radial(
        center,
        hubRadius,
        [
          Colors.white.withValues(alpha: 0.95),
          AppColors.paletteMintSoft.withValues(alpha: 0.9),
        ],
      );
    canvas.drawCircle(center, hubRadius, hubFill);

    final hubBorder = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..color = AppColors.paletteTeal.withValues(alpha: 0.5);
    canvas.drawCircle(center, hubRadius, hubBorder);

    final iconPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(0x1F4DE),
        style: const TextStyle(fontSize: 22),
      ),
      textDirection: TextDirection.ltr,
    );
    iconPainter.layout();
    iconPainter.paint(
      canvas,
      center.translate(-iconPainter.width / 2, -iconPainter.height / 2),
    );
  }

  void _drawPointer(Canvas canvas, Offset center, double radius) {
    final pointerY = center.dy - radius - 8;
    final pointer = Path()
      ..moveTo(center.dx, pointerY + 18)
      ..lineTo(center.dx - 14, pointerY - 4)
      ..lineTo(center.dx + 14, pointerY - 4)
      ..close();

    final paint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(center.dx, pointerY - 4),
        Offset(center.dx, pointerY + 18),
        [AppColors.paletteGold, AppColors.paletteCoral],
      )
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 0);

    canvas.drawPath(pointer, paint);

    final border = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = Colors.white.withValues(alpha: 0.8);
    canvas.drawPath(pointer, border);
  }

  @override
  bool shouldRepaint(covariant WheelPainter oldDelegate) {
    return oldDelegate.rotation != rotation || oldDelegate.contacts != contacts;
  }
}
