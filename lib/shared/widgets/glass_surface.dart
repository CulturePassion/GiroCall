import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/design/colors.dart';
import '../../core/design/tokens.dart';

/// Frosted glass effect surface for premium modern UI.
/// Use [frosted] for real backdrop blur (stronger glassmorphism).
class GlassSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? color;
  final bool frosted;
  final double blurSigma;

  const GlassSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = AppTokens.radiusLg,
    this.color,
    this.frosted = false,
    this.blurSigma = 10.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final surface = AppColors.cardSurface(context);

    // Refined glass alphas for vibrant brand + excellent dark mode
    final bgColor = color ?? surface.withValues(alpha: isDark ? 0.28 : 0.12);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : AppColors.vibrantGreen.withValues(alpha: 0.18);

    final glass = Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor, width: 0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.32 : 0.1),
            blurRadius: isDark ? 18 : 14,
            offset: const Offset(0, 6),
            spreadRadius: isDark ? -2 : 0,
          ),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );

    if (!frosted) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: glass,
      );
    }

    // True frosted glass with blur – modern premium feel
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(
          sigmaX: blurSigma,
          sigmaY: blurSigma,
        ),
        child: glass,
      ),
    );
  }
}
