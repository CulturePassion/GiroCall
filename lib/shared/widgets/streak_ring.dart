import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/design/colors.dart';
import '../../core/design/spacing.dart';

/// Progress ring for call streaks — design system hero metric.
class StreakRing extends StatelessWidget {
  final int streak;
  final int? goal;
  final double size;
  final String? label;

  const StreakRing({
    super.key,
    required this.streak,
    this.goal,
    this.size = 72,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final target = goal ?? math.max(streak, 1);
    final progress = (streak / target).clamp(0.0, 1.0);
    final ringColor = AppColors.orange;
    final trackColor =
        AppColors.isDark(context) ? AppColors.darkDivider : AppColors.grey200;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: size,
                height: size,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: size * 0.1,
                  backgroundColor: trackColor,
                  color: ringColor,
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.local_fire_department,
                    color: ringColor,
                    size: size * 0.22,
                  ),
                  Text(
                    '$streak',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: ringColor,
                          height: 1,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (label != null) ...[
          const SizedBox(height: AppSpacing.xxs),
          Text(
            label!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
