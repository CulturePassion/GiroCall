import 'package:flutter/material.dart';

import '../../core/design/colors.dart';
import '../../core/design/tokens.dart';

/// Interactive 1–5 star rating widget with 48dp touch targets.
class StarRating extends StatelessWidget {
  final int rating;
  final ValueChanged<int>? onChanged;
  final double size;

  const StarRating({
    super.key,
    required this.rating,
    this.onChanged,
    this.size = 28,
  });

  @override
  Widget build(BuildContext context) {
    final inactiveColor = AppColors.textMuted(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starIndex = index + 1;
        final isFilled = starIndex <= rating;
        return Semantics(
          label: 'Rate $starIndex stars',
          button: true,
          child: IconButton(
            onPressed:
                onChanged == null ? null : () => onChanged!(starIndex),
            icon: Icon(
              isFilled ? Icons.star_rounded : Icons.star_border_rounded,
              size: size,
              color: isFilled ? AppColors.accentCoral : inactiveColor,
            ),
            constraints: const BoxConstraints(
              minWidth: AppTokens.minTouchTarget,
              minHeight: AppTokens.minTouchTarget,
            ),
            padding: EdgeInsets.zero,
          ),
        );
      }),
    );
  }
}