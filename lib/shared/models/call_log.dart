import 'package:flutter/foundation.dart';

/// A logged phone call.
@immutable
class CallLog {
  final String? id;
  final String userId;
  final String contactId;
  final DateTime calledAt;
  final int? durationSeconds;
  final int? callRating;
  final String? notes;
  final DateTime? createdAt;

  const CallLog({
    this.id,
    required this.userId,
    required this.contactId,
    required this.calledAt,
    this.durationSeconds,
    this.callRating,
    this.notes,
    this.createdAt,
  });

  CallLog copyWith({
    String? id,
    String? userId,
    String? contactId,
    DateTime? calledAt,
    int? durationSeconds,
    int? callRating,
    String? notes,
    DateTime? createdAt,
  }) {
    return CallLog(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      contactId: contactId ?? this.contactId,
      calledAt: calledAt ?? this.calledAt,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      callRating: callRating ?? this.callRating,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'contact_id': contactId,
      'called_at': calledAt.toIso8601String(),
      'duration_seconds': durationSeconds,
      'call_rating': callRating,
      'notes': notes,
    };
  }

  factory CallLog.fromJson(Map<String, dynamic> json) {
    return CallLog(
      id: json['id'] as String?,
      userId: json['user_id'] as String,
      contactId: json['contact_id'] as String,
      calledAt: DateTime.parse(json['called_at'] as String),
      durationSeconds: json['duration_seconds'] as int?,
      callRating: json['call_rating'] as int?,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }
}
