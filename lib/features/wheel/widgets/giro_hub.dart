import 'package:flutter/material.dart';

/// Center hub — globe, phone, and "Giro" wordmark (brand wheel core).
class GiroHub extends StatelessWidget {
  final bool isSpinning;
  final double size;

  const GiroHub({
    super.key,
    this.isSpinning = false,
    this.size = 88,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: isSpinning ? 1.06 : 1.0,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const RadialGradient(
            colors: [
              Color(0xFFE0F7FA),
              Color(0xFF4FC3F7),
              Color(0xFF0288D1),
            ],
            stops: [0.2, 0.65, 1.0],
          ),
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: Size(size, size),
              painter: _GlobeGridPainter(),
            ),
            Icon(
              Icons.phone_in_talk_rounded,
              size: size * 0.34,
              color: const Color(0xFF0A3D62),
            ),
            Positioned(
              bottom: size * 0.1,
              child: Text(
                'Giro',
                style: TextStyle(
                  fontSize: size * 0.17,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.5,
                  shadows: const [
                    Shadow(
                      color: Color(0x88000000),
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlobeGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 6;

    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawCircle(center, r * 0.85, gridPaint);
    canvas.drawCircle(center, r * 0.55, gridPaint);

    for (var i = -2; i <= 2; i++) {
      final y = center.dy + i * r * 0.22;
      canvas.drawLine(
        Offset(center.dx - r * 0.8, y),
        Offset(center.dx + r * 0.8, y),
        gridPaint,
      );
    }

    for (var i = -2; i <= 2; i++) {
      final x = center.dx + i * r * 0.22;
      canvas.drawLine(
        Offset(x, center.dy - r * 0.8),
        Offset(x, center.dy + r * 0.8),
        gridPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
