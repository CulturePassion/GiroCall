import 'package:flutter/material.dart';

import '../../core/design/colors.dart';
import '../../core/design/spacing.dart';
import '../../core/design/tokens.dart';

/// Opaque premium surface — readable on any background.
class PremiumCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? accentColor;

  const PremiumCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.sm),
    this.borderRadius = AppTokens.radiusLg,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final surface = AppColors.cardSurface(context);
    final borderColor = accentColor?.withValues(alpha: 0.25) ??
        (isDark ? AppColors.darkDivider : AppColors.grey200);
    final shadowColor =
        (accentColor ?? AppColors.main).withValues(alpha: isDark ? 0.15 : 0.08);

    return Material(
      color: surface,
      elevation: isDark ? 2 : 1,
      shadowColor: shadowColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        side: BorderSide(color: borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}
