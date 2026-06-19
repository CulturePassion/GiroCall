import 'package:flutter/material.dart';

import '../../../core/design/colors.dart';
import '../../../core/design/spacing.dart';
import '../../../core/design/tokens.dart';
import '../../../shared/models/presence_status.dart';

class PresenceSelector extends StatelessWidget {
  final PresenceType? selected;
  final ValueChanged<PresenceType> onSelected;
  final TextEditingController? customMessageController;

  const PresenceSelector({
    super.key,
    required this.selected,
    required this.onSelected,
    this.customMessageController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'How are you feeling?',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textMuted(context),
              ),
        ),
        const SizedBox(height: AppSpacing.xs),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 420;
            if (isWide) {
              return Row(
                children: PresenceType.values.map((type) {
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: type != PresenceType.custom ? AppSpacing.xs : 0,
                      ),
                      child: _PresenceChip(
                        type: type,
                        selected: selected == type,
                        onTap: () => onSelected(type),
                      ),
                    ),
                  );
                }).toList(),
              );
            }

            return Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: PresenceType.values.map((type) {
                return SizedBox(
                  width: (constraints.maxWidth - AppSpacing.xs * 2) / 3,
                  child: _PresenceChip(
                    type: type,
                    selected: selected == type,
                    onTap: () => onSelected(type),
                  ),
                );
              }).toList(),
            );
          },
        ),
        if (selected == PresenceType.custom) ...[
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: customMessageController,
            decoration: InputDecoration(
              labelText: 'Custom status',
              hintText: 'e.g. On vacation until Friday',
              prefixIcon: const Icon(Icons.chat_bubble_outline),
              filled: true,
              fillColor: AppColors.isDark(context)
                  ? AppColors.darkDivider.withValues(alpha: 0.35)
                  : AppColors.grey100,
            ),
            maxLength: 80,
            textCapitalization: TextCapitalization.sentences,
          ),
        ],
      ],
    );
  }
}

class _PresenceChip extends StatelessWidget {
  final PresenceType type;
  final bool selected;
  final VoidCallback onTap;

  const _PresenceChip({
    required this.type,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = type.color;
    final isDark = AppColors.isDark(context);

    return Material(
      color: selected
          ? color.withValues(alpha: isDark ? 0.22 : 0.12)
          : (isDark ? AppColors.darkDivider : AppColors.grey100),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        side: BorderSide(
          color: selected ? color : Colors.transparent,
          width: selected ? 2 : 0,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(minHeight: AppTokens.minTouchTarget),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.sm,
              horizontal: AppSpacing.xxs,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: selected
                        ? color.withValues(alpha: 0.2)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    type.icon,
                    color: selected ? color : AppColors.textMuted(context),
                    size: 24,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  type == PresenceType.meeting ? 'Meeting' : type.label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight:
                            selected ? FontWeight.w800 : FontWeight.w600,
                        color: selected ? color : null,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
