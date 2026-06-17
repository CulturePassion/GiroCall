import 'package:flutter/material.dart';

import '../../../core/app_colors.dart';
import '../../../shared/models/presence_status.dart';

/// WhatsApp-style status ring around a contact avatar.
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
              gradient: LinearGradient(
                colors: [
                  ringColor,
                  ringColor.withValues(alpha: 0.5),
                  AppColors.accentCoral,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            )
          : null,
      child: CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.primaryTeal,
        backgroundImage:
            imageUrl != null ? NetworkImage(imageUrl!) : null,
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
    );
  }
}