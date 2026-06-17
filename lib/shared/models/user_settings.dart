import 'package:flutter/foundation.dart';

/// User-configurable app settings.
@immutable
class UserSettings {
  final String userId;
  final DateTime? dailyReminderTime;
  final int dailyCallGoal;
  final int timezoneOffsetMinutes;
  final DateTime? createdAt;

  const UserSettings({
    required this.userId,
    this.dailyReminderTime,
    this.dailyCallGoal = 2,
    this.timezoneOffsetMinutes = 0,
    this.createdAt,
  });

  static const _unset = Object();

  UserSettings copyWith({
    String? userId,
    Object? dailyReminderTime = _unset,
    int? dailyCallGoal,
    int? timezoneOffsetMinutes,
    Object? createdAt = _unset,
  }) {
    return UserSettings(
      userId: userId ?? this.userId,
      dailyReminderTime: identical(dailyReminderTime, _unset)
          ? this.dailyReminderTime
          : dailyReminderTime as DateTime?,
      dailyCallGoal: dailyCallGoal ?? this.dailyCallGoal,
      timezoneOffsetMinutes:
          timezoneOffsetMinutes ?? this.timezoneOffsetMinutes,
      createdAt: identical(createdAt, _unset)
          ? this.createdAt
          : createdAt as DateTime?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'daily_reminder_time': _formatTime(dailyReminderTime),
      'daily_call_goal': dailyCallGoal,
      'timezone_offset_minutes': timezoneOffsetMinutes,
    };
  }

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      userId: json['user_id'] as String,
      dailyReminderTime: _parseTime(json['daily_reminder_time'] as String?),
      dailyCallGoal: json['daily_call_goal'] as int? ?? 2,
      timezoneOffsetMinutes: json['timezone_offset_minutes'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  static String? _formatTime(DateTime? time) {
    if (time == null) return null;
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
  }

  static DateTime? _parseTime(String? time) {
    if (time == null || time.isEmpty) return null;
    final parts = time.split(':');
    if (parts.length < 2) return null;
    final now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }
}
