import 'package:flutter/material.dart';

import '../../core/design/colors.dart';
import '../../core/design/spacing.dart';
import '../../core/design/tokens.dart';

/// Premium search input for contact lists and filters.
class SearchField extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String hintText;
  final VoidCallback? onClear;

  const SearchField({
    super.key,
    this.controller,
    this.onChanged,
    this.hintText = 'Search people…',
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Search contacts',
      textField: true,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: Theme.of(context).textTheme.bodyLarge,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: onClear != null
              ? IconButton(
                  tooltip: 'Clear search',
                  onPressed: onClear,
                  icon: const Icon(Icons.close_rounded),
                  constraints: const BoxConstraints(
                    minWidth: AppTokens.minTouchTarget,
                    minHeight: AppTokens.minTouchTarget,
                  ),
                )
              : null,
          filled: true,
          fillColor: AppColors.isDark(context)
              ? AppColors.darkSurface
              : AppColors.grey100,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs,
            vertical: AppSpacing.xs,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}