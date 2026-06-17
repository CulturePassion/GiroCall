import 'package:flutter/material.dart';

import '../../core/app_colors.dart';

/// Relationship category for organizing the address book.
enum ContactTag {
  friends('friends', 'Friends', Icons.favorite_outline, AppColors.accentCoral),
  family('family', 'Family', Icons.home_outlined, AppColors.secondaryBlue),
  work('work', 'Work', Icons.work_outline, AppColors.primaryTeal),
  business('business', 'Business', Icons.business_center_outlined,
      AppColors.persianBlue);

  const ContactTag(this.value, this.label, this.icon, this.color);

  final String value;
  final String label;
  final IconData icon;
  final Color color;

  static ContactTag? fromValue(String? value) {
    if (value == null) return null;
    for (final tag in ContactTag.values) {
      if (tag.value == value) return tag;
    }
    return null;
  }
}
