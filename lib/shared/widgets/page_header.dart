import 'package:flutter/material.dart';

import '../../core/design/spacing.dart';

/// Consistent section header for feature screens.
class PageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool onHeroBackground;

  const PageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onHeroBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    final titleColor = onHeroBackground
        ? Colors.white
        : Theme.of(context).colorScheme.onSurface;
    final subtitleColor = onHeroBackground
        ? Colors.white.withValues(alpha: 0.9)
        : Theme.of(context).colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                  height: 1.3,
                ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AppSpacing.xxs),
            Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: subtitleColor,
                    height: 1.5,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}