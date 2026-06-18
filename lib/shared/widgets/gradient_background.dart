import 'package:flutter/material.dart';

import '../../core/design/colors.dart';

/// Warm, kind gradient for hero screens (wheel, login, profile).
class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final colors = isDark
        ? const [
            AppColors.darkHeroGradientStart,
            AppColors.darkHeroGradientMid,
            AppColors.darkHeroGradientEnd,
          ]
        : const [
            AppColors.heroGradientStart,
            AppColors.heroGradientMid,
            AppColors.heroGradientEnd,
          ];

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
          stops: const [0.0, 0.55, 1.0],
        ),
      ),
      child: child,
    );
  }
}