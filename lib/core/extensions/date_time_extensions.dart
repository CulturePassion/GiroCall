extension DateTimeExtensions on DateTime {
  /// Returns true if this date is today in local time.
  bool get isToday {
    final local = toLocal();
    final now = DateTime.now();
    return local.year == now.year &&
        local.month == now.month &&
        local.day == now.day;
  }

  /// Returns true if this date is yesterday in local time.
  bool get isYesterday {
    final local = toLocal();
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return local.year == yesterday.year &&
        local.month == yesterday.month &&
        local.day == yesterday.day;
  }

  /// Returns the number of days between this date and now.
  int get daysAgo {
    final now = DateTime.now();
    final difference = now.difference(toLocal());
    return difference.inDays;
  }

  /// Formats as a friendly relative string, e.g. "Today", "Yesterday",
  /// "3 days ago".
  String toRelativeDateString() {
    if (isToday) return 'Today';
    if (isYesterday) return 'Yesterday';
    final days = daysAgo;
    if (days < 30) return '$days days ago';
    if (days < 365) return '${days ~/ 30} months ago';
    return '${days ~/ 365} years ago';
  }
}
