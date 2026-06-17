import 'package:flutter_test/flutter_test.dart';
import 'package:girocall/features/stats/providers/stats_provider.dart';
import 'package:girocall/shared/models/call_log.dart';

void main() {
  group('UserStats', () {
    test('empty stats when no logs', () {
      const stats = UserStats.empty();
      expect(stats.totalCalls, 0);
      expect(stats.currentStreak, 0);
      expect(stats.averageRating, 0);
    });
  });

  group('computeStreaks', () {
    test('current streak is 0 when last call was more than a day ago', () {
      final logs = [
        CallLog(
          userId: 'u1',
          contactId: 'c1',
          calledAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
      ];
      final streaks = computeStreaks(logs);
      expect(streaks.current, 0);
      expect(streaks.longest, 1);
    });

    test('current streak counts consecutive days', () {
      final now = DateTime.now();
      final logs = [
        CallLog(userId: 'u1', contactId: 'c1', calledAt: now),
        CallLog(
          userId: 'u1',
          contactId: 'c2',
          calledAt: now.subtract(const Duration(days: 1)),
        ),
        CallLog(
          userId: 'u1',
          contactId: 'c3',
          calledAt: now.subtract(const Duration(days: 2)),
        ),
      ];
      final streaks = computeStreaks(logs);
      expect(streaks.current, 3);
      expect(streaks.longest, 3);
    });
  });
}
