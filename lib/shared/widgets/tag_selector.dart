import 'package:flutter/material.dart';

import '../models/contact_tag.dart';
import 'contact_tag_chip.dart';

class TagSelector extends StatelessWidget {
  final ContactTag? selected;
  final ValueChanged<ContactTag?> onChanged;

  const TagSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ContactTagChip(
          selected: selected == null,
          onTap: () => onChanged(null),
        ),
        ...ContactTag.values.map(
          (tag) => ContactTagChip(
            tag: tag,
            selected: selected == tag,
            onTap: () => onChanged(tag),
          ),
        ),
      ],
    );
  }
}
