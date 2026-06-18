import 'package:flutter/material.dart';

import '../../../core/design/colors.dart';
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
        Row(
          children: PresenceType.values.map((type) {
            final isSelected = selected == type;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: type != PresenceType.custom ? 8 : 0,
                ),
                child: _PresenceChip(
                  type: type,
                  selected: isSelected,
                  onTap: () => onSelected(type),
                ),
              ),
            );
          }).toList(),
        ),
        if (selected == PresenceType.custom) ...[
          const SizedBox(height: 12),
          TextField(
            controller: customMessageController,
            decoration: const InputDecoration(
              labelText: 'Custom status',
              hintText: 'e.g. On vacation until Friday',
              prefixIcon: Icon(Icons.chat_bubble_outline),
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
    return Material(
      color: selected
          ? color.withValues(alpha: 0.15)
          : Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          child: Column(
            children: [
              Icon(
                type.icon,
                color: selected ? color : AppColors.textSecondary,
                size: 26,
              ),
              const SizedBox(height: 6),
              Text(
                type == PresenceType.meeting ? 'Meeting' : type.label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected ? color : null,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
