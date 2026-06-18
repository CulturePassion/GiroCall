import 'package:flutter/material.dart';

import '../../core/design/colors.dart';

/// Quick availability status (WhatsApp / iMessage style).
enum PresenceType {
  available('available', 'Available', Icons.check_circle, AppColors.success),
  meeting('meeting', 'In a meeting', Icons.event_busy, AppColors.accentCoral),
  custom('custom', 'Custom', Icons.edit_outlined, AppColors.secondaryBlue);

  const PresenceType(this.value, this.label, this.icon, this.color);

  final String value;
  final String label;
  final IconData icon;
  final Color color;

  static PresenceType? fromValue(String? value) {
    if (value == null) return null;
    for (final type in PresenceType.values) {
      if (type.value == value) return type;
    }
    return null;
  }

  String displayMessage(String? customMessage) {
    if (this == PresenceType.custom) {
      final trimmed = customMessage?.trim();
      return trimmed?.isNotEmpty == true ? trimmed! : 'Set a custom status';
    }
    return label;
  }
}
