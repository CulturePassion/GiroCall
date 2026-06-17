import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/app_colors.dart';

/// Colorful mesh-style backdrop for glass surfaces.
class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      AppColors.darkBackground,
                      AppColors.persianBlue.withValues(alpha: 0.35),
                      AppColors.darkBackground,
                    ]
                  : [
                      AppColors.mainPale,
                      AppColors.mainSoft.withValues(alpha: 0.55),
                      AppColors.mainPale,
                    ],
            ),
          ),
        ),
        ..._blobs(isDark),
        child,
      ],
    );
  }

  List<Widget> _blobs(bool isDark) {
    final alpha = isDark ? 0.18 : 0.28;
    return [
      Positioned(
        top: -80,
        right: -40,
        child: _colorBlob(AppColors.orange, 200, alpha),
      ),
      Positioned(
        top: 120,
        left: -60,
        child: _colorBlob(AppColors.main, 180, alpha * 0.9),
      ),
      Positioned(
        bottom: 80,
        right: -20,
        child: _colorBlob(AppColors.cadmiumOrange, 160, alpha * 0.85),
      ),
      Positioned(
        bottom: -40,
        left: 40,
        child: _colorBlob(AppColors.royalBlue, 140, alpha * 0.7),
      ),
    ];
  }

  Widget _colorBlob(Color color, double size, double alpha) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 48, sigmaY: 48),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: alpha),
        ),
      ),
    );
  }
}
