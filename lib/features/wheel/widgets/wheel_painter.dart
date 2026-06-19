import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../../../core/design/colors.dart';
import '../../../shared/models/contact.dart';

/// Brand-inspired Giro wheel — rainbow segments, people chips, premium rim.
class WheelPainter extends CustomPainter {
  final List<Contact> contacts;
  final double rotation;

  WheelPainter({
    required this.contacts,
    required this.rotation,
  });

  static const _hubGlobeRadiusFactor = 0.34;

  @override
  void paint(Canvas canvas, Size size) {
    if (contacts.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 10;
    final sliceAngle = 2 * pi / contacts.length;
    final hubCutout = radius * _hubGlobeRadiusFactor;

    _drawOuterRim(canvas, center, radius);
    _drawInnerShadowRing(canvas, center, radius);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation * pi / 180);
    canvas.translate(-center.dx, -center.dy);

    for (var i = 0; i < contacts.length; i++) {
      final baseColor =
          AppColors.wheelSliceColors[i % AppColors.wheelSliceColors.length];
      final start = i * sliceAngle - pi / 2;

      _drawSlice(
        canvas,
        center,
        radius,
        hubCutout,
        start,
        sliceAngle,
        baseColor,
      );
      _drawSliceSeparator(canvas, center, radius, hubCutout, start);
      _drawPersonChip(
        canvas,
        center,
        radius,
        start + sliceAngle / 2,
        contacts[i].name.isNotEmpty ? contacts[i].name[0].toUpperCase() : '?',
        baseColor,
      );
    }

    canvas.restore();

    _drawHubMask(canvas, center, hubCutout);
    _drawPointer(canvas, center, radius);
  }

  void _drawOuterRim(Canvas canvas, Offset center, double radius) {
    canvas.drawCircle(
      center,
      radius + 5,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6,
    );
    canvas.drawCircle(
      center,
      radius + 2,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..shader = const SweepGradient(
          colors: [
            AppColors.vibrantGreen,
            AppColors.brightOrange,
            AppColors.goldenYellowOrange,
            AppColors.pinkMagenta,
            AppColors.softBluePurple,
            AppColors.vibrantGreen,
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
  }

  void _drawInnerShadowRing(Canvas canvas, Offset center, double radius) {
    canvas.drawCircle(
      center,
      radius - 2,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
  }

  void _drawSlice(
    Canvas canvas,
    Offset center,
    double outerRadius,
    double innerRadius,
    double start,
    double sweep,
    Color color,
  ) {
    final path = Path()
      ..moveTo(
        center.dx + innerRadius * cos(start),
        center.dy + innerRadius * sin(start),
      )
      ..arcTo(
        Rect.fromCircle(center: center, radius: outerRadius - 14),
        start,
        sweep,
        false,
      )
      ..arcTo(
        Rect.fromCircle(center: center, radius: innerRadius),
        start + sweep,
        -sweep,
        false,
      )
      ..close();

    final lighter = Color.lerp(color, Colors.white, 0.18)!;
    final paint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        colors: [lighter, color, color.withValues(alpha: 0.92)],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: outerRadius));

    canvas.drawPath(path, paint);
  }

  void _drawSliceSeparator(
    Canvas canvas,
    Offset center,
    double outerRadius,
    double innerRadius,
    double angle,
  ) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(
        center.dx + innerRadius * cos(angle),
        center.dy + innerRadius * sin(angle),
      ),
      Offset(
        center.dx + (outerRadius - 14) * cos(angle),
        center.dy + (outerRadius - 14) * sin(angle),
      ),
      paint,
    );
  }

  void _drawPersonChip(
    Canvas canvas,
    Offset center,
    double radius,
    double angle,
    String initial,
    Color segmentColor,
  ) {
    final chipRadius = radius * 0.11;
    final offset = Offset(
      center.dx + radius * 0.68 * cos(angle),
      center.dy + radius * 0.68 * sin(angle),
    );

    canvas.drawCircle(
      offset,
      chipRadius + 2,
      Paint()..color = Colors.white,
    );

    canvas.drawCircle(
      offset,
      chipRadius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white,
            Color.lerp(segmentColor, Colors.white, 0.35)!,
          ],
        ).createShader(Rect.fromCircle(center: offset, radius: chipRadius)),
    );

    final textPainter = TextPainter(
      text: TextSpan(
        text: initial,
        style: TextStyle(
          color: _contrastTextColor(segmentColor),
          fontSize: chipRadius * 1.1,
          fontWeight: FontWeight.w800,
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

  Color _contrastTextColor(Color bg) {
    return bg.computeLuminance() > 0.55
        ? const Color(0xFF1E293B)
        : Colors.white;
  }

  void _drawHubMask(Canvas canvas, Offset center, double hubRadius) {
    canvas.drawCircle(
      center,
      hubRadius + 4,
      Paint()..color = Colors.white.withValues(alpha: 0.15),
    );
  }

  void _drawPointer(Canvas canvas, Offset center, double radius) {
    final pointerY = center.dy - radius - 10;
    final pointer = Path()
      ..moveTo(center.dx, pointerY + 26)
      ..lineTo(center.dx - 18, pointerY - 4)
      ..lineTo(center.dx + 18, pointerY - 4)
      ..close();

    canvas.drawPath(
      pointer,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.brightOrange, AppColors.goldenYellowOrange],
        ).createShader(
          Rect.fromPoints(
            Offset(center.dx - 18, pointerY - 4),
            Offset(center.dx + 18, pointerY + 26),
          ),
        ),
    );

    canvas.drawPath(
      pointer,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant WheelPainter oldDelegate) {
    return oldDelegate.rotation != rotation ||
        !listEquals(oldDelegate.contacts, contacts);
  }
}
