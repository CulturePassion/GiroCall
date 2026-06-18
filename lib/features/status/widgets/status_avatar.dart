import 'package:flutter/material.dart';

import '../../../core/design/colors.dart';
import '../../../shared/models/presence_status.dart';

/// Solid ring around a contact avatar for status.
class StatusAvatar extends StatelessWidget {
  final String initials;
  final PresenceType? statusType;
  final double radius;
  final String? imageUrl;

  const StatusAvatar({
    super.key,
    required this.initials,
    this.statusType,
    this.radius = 24,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final ringColor = statusType?.color ?? AppColors.primaryTeal;
    final hasStatus = statusType != null;

    return Container(
      padding: EdgeInsets.all(hasStatus ? 3 : 0),
      decoration: hasStatus
          ? BoxDecoration(
              shape: BoxShape.circle,
              color: ringColor,
            )
          : null,
      child: Container(
        padding: EdgeInsets.all(hasStatus ? 2 : 0),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: CircleAvatar(
          radius: radius,
          backgroundColor: AppColors.primaryTeal,
          backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
          child: imageUrl == null
              ? Text(
                  initials,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: radius * 0.75,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
