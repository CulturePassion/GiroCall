import 'package:flutter/foundation.dart';

import 'presence_status.dart';

/// A time-limited status update visible to GiroCall contacts (24h).
@immutable
class UserStatusStory {
  final String id;
  final String userId;
  final String textContent;
  final PresenceType statusType;
  final DateTime createdAt;
  final DateTime expiresAt;

  const UserStatusStory({
    required this.id,
    required this.userId,
    required this.textContent,
    required this.statusType,
    required this.createdAt,
    required this.expiresAt,
  });

  bool get isActive => expiresAt.isAfter(DateTime.now());

  factory UserStatusStory.fromJson(Map<String, dynamic> json) {
    return UserStatusStory(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      textContent: json['text_content'] as String,
      statusType: PresenceType.fromValue(json['status_type'] as String?) ??
          PresenceType.custom,
      createdAt: DateTime.parse(json['created_at'] as String),
      expiresAt: DateTime.parse(json['expires_at'] as String),
    );
  }

  Map<String, dynamic> toInsertJson({
    required String userId,
    required PresenceType type,
    required String text,
  }) {
    final now = DateTime.now().toUtc();
    return {
      'user_id': userId,
      'text_content': text,
      'status_type': type.value,
      'expires_at': now.add(const Duration(hours: 24)).toIso8601String(),
    };
  }
}

/// A contact matched to an active GiroCall user status.
@immutable
class ContactStatusUpdate {
  final String contactId;
  final String contactName;
  final String? contactPhone;
  final String? avatarUrl;
  final PresenceType statusType;
  final String message;
  final DateTime updatedAt;
  final bool isStory;

  const ContactStatusUpdate({
    required this.contactId,
    required this.contactName,
    this.contactPhone,
    this.avatarUrl,
    required this.statusType,
    required this.message,
    required this.updatedAt,
    this.isStory = false,
  });
}
