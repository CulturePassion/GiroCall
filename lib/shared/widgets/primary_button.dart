import 'package:flutter/material.dart';

import '../../core/design/colors.dart';
import '../../core/design/spacing.dart';
import '../../core/design/tokens.dart';

/// Standard primary action button with loading state.
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool fullWidth;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.backgroundColor,
    this.foregroundColor,
    this.fullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  foregroundColor ?? Colors.white,
                ),
              ),
            )
          : icon != null
              ? Icon(icon, size: 20)
              : null,
      label: isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: SizedBox.shrink(),
            )
          : Text(label),
      style: FilledButton.styleFrom(
        backgroundColor: backgroundColor ?? AppColors.orange,
        foregroundColor: foregroundColor ?? Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        ),
        elevation: 4,
        shadowColor: AppColors.orange.withValues(alpha: 0.4),
        minimumSize: Size(fullWidth ? double.infinity : 0, 48),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
