import 'package:flutter/material.dart';

import '../../core/design/colors.dart';
import '../../core/design/microcopy.dart';
import '../../core/design/spacing.dart';
import '../../core/errors/app_error_mapper.dart';

/// Inline dismissible banner for non-blocking errors (e.g. refresh failed).
class ErrorBanner extends StatelessWidget {
  final Object error;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;

  const ErrorBanner({
    super.key,
    required this.error,
    this.onRetry,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final appError = mapError(error);

    return Material(
      color: AppColors.error.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.info_outline_rounded,
              color: AppColors.error,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                appError.userMessage,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      height: 1.4,
                    ),
              ),
            ),
            if (onRetry != null && appError.isRetryable)
              TextButton(
                onPressed: onRetry,
                child: const Text(Microcopy.errorRetry),
              ),
            if (onDismiss != null)
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: onDismiss,
                visualDensity: VisualDensity.compact,
              ),
          ],
        ),
      ),
    );
  }
}
