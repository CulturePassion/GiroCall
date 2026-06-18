import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions/date_time_extensions.dart';
import '../../../shared/models/call_log.dart';
import '../../call_log/providers/call_log_notifier.dart';

/// Aggregated stats for the user.
class UserStats {
  final int totalCalls;
  final int uniqueContactsCalled;
  final int currentStreak;
  final int longestStreak;
  final double averageRating;
  final int callsToday;
  final int callsThisWeek;
  final int callsThisMonth;

  const UserStats({
    required this.totalCalls,
    required this.uniqueContactsCalled,
    required this.currentStreak,
    required this.longestStreak,
    required this.averageRating,
    required this.callsToday,
    required this.callsThisWeek,
    required this.callsThisMonth,
  });

  const UserStats.empty()
      : totalCalls = 0,
        uniqueContactsCalled = 0,
        currentStreak = 0,
        longestStreak = 0,
        averageRating = 0,
        callsToday = 0,
        callsThisWeek = 0,
        callsThisMonth = 0;
}

final statsProvider = Provider<UserStats>((ref) {
  final logsAsync = ref.watch(callLogNotifierProvider);
  final logs = logsAsync.value ?? [];

  if (logs.isEmpty) return const UserStats.empty();

  final now = DateTime.now();

  final uniqueContacts = logs.map((l) => l.contactId).toSet();
  final ratings =
      logs.where((l) => l.callRating != null).map((l) => l.callRating!);

  final callsToday = logs.where((l) => l.calledAt.isToday).length;
  final callsThisWeek =
      logs.where((l) => now.difference(l.calledAt).inDays <= 7).length;
  final callsThisMonth =
      logs.where((l) => now.difference(l.calledAt).inDays <= 30).length;

  final streaks = computeStreaks(logs);

  return UserStats(
    totalCalls: logs.length,
    uniqueContactsCalled: uniqueContacts.length,
    currentStreak: streaks.current,
    longestStreak: streaks.longest,
    averageRating:
        ratings.isEmpty ? 0 : ratings.reduce((a, b) => a + b) / ratings.length,
    callsToday: callsToday,
    callsThisWeek: callsThisWeek,
    callsThisMonth: callsThisMonth,
  );
});

class StreakResult {
  final int current;
  final int longest;

  const StreakResult({required this.current, required this.longest});
}

StreakResult computeStreaks(List<CallLog> logs) {
  if (logs.isEmpty) return const StreakResult(current: 0, longest: 0);

  final days = logs
      .map((l) {
        final d = l.calledAt.toLocal();
        return DateTime(d.year, d.month, d.day);
      })
      .toSet()
      .toList();
  days.sort((a, b) => b.compareTo(a));

  var current = 0;
  final today = DateTime.now();
  final todayDate = DateTime(today.year, today.month, today.day);

  if (days.first == todayDate ||
      days.first == todayDate.subtract(const Duration(days: 1))) {
    current = 1;
    for (var i = 1; i < days.length; i++) {
      if (days[i] == days[i - 1].subtract(const Duration(days: 1))) {
        current++;
      } else {
        break;
      }
    }
  }

  var longest = 1;
  var run = 1;
  for (var i = 1; i < days.length; i++) {
    if (days[i] == days[i - 1].subtract(const Duration(days: 1))) {
      run++;
      if (run > longest) longest = run;
    } else {
      run = 1;
    }
  }

  return StreakResult(current: current, longest: longest);
}