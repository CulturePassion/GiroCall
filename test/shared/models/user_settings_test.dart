import 'package:flutter_test/flutter_test.dart';
import 'package:girocall/shared/models/user_settings.dart';

void main() {
  group('UserSettings', () {
    test('formats daily reminder time as HH:MM:SS', () {
      final settings = UserSettings(
        userId: 'u1',
        dailyReminderTime: DateTime(2026, 6, 17, 19, 30),
        dailyCallGoal: 2,
      );
      final json = settings.toJson();
      expect(json['daily_reminder_time'], '19:30:00');
    });

    test('parses time string back to DateTime', () {
      final json = {
        'user_id': 'u1',
        'daily_reminder_time': '08:15:00',
        'daily_call_goal': 3,
      };
      final settings = UserSettings.fromJson(json);
      expect(settings.dailyCallGoal, 3);
      expect(settings.dailyReminderTime?.hour, 8);
      expect(settings.dailyReminderTime?.minute, 15);
    });
  });
}
