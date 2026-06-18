import 'package:flutter/material.dart';

import '../models/contact_tag.dart';

class ContactTagChip extends StatelessWidget {
  final ContactTag? tag;
  final bool selected;
  final bool showIcon;
  final VoidCallback? onTap;

  const ContactTagChip({
    super.key,
    this.tag,
    this.selected = false,
    this.showIcon = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final label = tag?.label ?? 'All';
    final color = tag?.color ?? Theme.of(context).colorScheme.primary;

    return FilterChip(
      label: Text(label),
      avatar: showIcon && tag != null
          ? Icon(tag!.icon, size: 18, color: selected ? Colors.white : color)
          : null,
      selected: selected,
      onSelected: onTap == null ? null : (_) => onTap!(),
      selectedColor: color,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: selected ? Colors.white : null,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
      ),
      side: BorderSide(
        color: selected ? Colors.transparent : color,
        width: 1.5,
      ),
    );
  }
}
