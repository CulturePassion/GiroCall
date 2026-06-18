import 'package:flutter/material.dart';

import '../../core/design/colors.dart';

/// Interactive 1-5 star rating widget.
class StarRating extends StatelessWidget {
  final int rating;
  final ValueChanged<int>? onChanged;
  final double size;

  const StarRating({
    super.key,
    required this.rating,
    this.onChanged,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starIndex = index + 1;
        final isFilled = starIndex <= rating;
        return GestureDetector(
          onTap: onChanged == null ? null : () => onChanged!(starIndex),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              isFilled ? Icons.star_rounded : Icons.star_border_rounded,
              size: size,
              color: isFilled ? AppColors.accentCoral : AppColors.textSecondary,
            ),
          ),
        );
      }),
    );
  }
}
