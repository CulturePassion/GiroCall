import 'package:flutter/material.dart';

import '../../core/design/colors.dart';
import '../../core/design/microcopy.dart';
import '../../core/design/spacing.dart';
import '../../core/design/tokens.dart';
import '../../core/errors/app_error.dart';
import '../../core/errors/app_error_mapper.dart';
import 'premium_card.dart';

/// Full-page error with optional retry — mirrors [EmptyState] styling.
class ErrorState extends StatelessWidget {
  final Object error;
  final String? title;
  final VoidCallback? onRetry;

  const ErrorState({
    super.key,
    required this.error,
    this.title,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final appError = mapError(error);
    final showRetry = onRetry != null && appError.isRetryable;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: PremiumCard(
          accentColor: AppColors.error,
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.25),
                    width: 2,
                  ),
                ),
                child: Icon(
                  _iconFor(appError),
                  size: 40,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                title ?? Microcopy.errorTitle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                appError.userMessage,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                    ),
                textAlign: TextAlign.center,
              ),
              if (showRetry) ...[
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text(Microcopy.errorRetry),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.vibrantGreen,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(
                        AppTokens.minTouchTarget,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconFor(AppError error) {
    return switch (error.category) {
      AppErrorCategory.network => Icons.wifi_off_rounded,
      AppErrorCategory.auth => Icons.lock_reset_rounded,
      AppErrorCategory.permission => Icons.block_rounded,
      AppErrorCategory.platformUnsupported => Icons.devices_rounded,
      _ => Icons.error_outline_rounded,
    };
  }
}
