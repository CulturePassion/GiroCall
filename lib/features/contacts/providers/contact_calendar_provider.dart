import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/contact.dart';
import '../../call_log/providers/call_log_notifier.dart';
import '../models/calendar_day_event.dart';
import 'contacts_notifier.dart';

/// Calendar markers for a month — past calls + recommended future calls.
final contactCalendarMonthProvider =
    Provider.family<List<CalendarDayEvent>, DateTime>((ref, month) {
  final contacts = ref.watch(contactsNotifierProvider).value ?? [];
  final logs = ref.watch(callLogNotifierProvider).value ?? [];
  final focused = DateTime(month.year, month.month);

  final events = <CalendarDayEvent>[];

  for (final log in logs) {
    if (!_sameMonth(log.calledAt, focused)) continue;
    final contact = contacts.cast<Contact?>().firstWhere(
          (c) => c?.id == log.contactId,
          orElse: () => null,
        );
    if (contact == null) continue;
    events.add(
      CalendarDayEvent(
        date: _dateOnly(log.calledAt),
        kind: CalendarEventKind.pastCall,
        contact: contact,
        rating: log.callRating,
        logId: log.id,
      ),
    );
  }

  for (final contact in contacts) {
    final recommended = contact.nextRecommendedCallAt;
    if (!_sameMonth(recommended, focused)) continue;
    events.add(
      CalendarDayEvent(
        date: _dateOnly(recommended),
        kind: CalendarEventKind.recommendedCall,
        contact: contact,
      ),
    );
  }

  events.sort((a, b) => a.date.compareTo(b.date));
  return events;
});

/// Events for one contact in the visible month.
final contactCalendarForContactProvider =
    Provider.family<List<CalendarDayEvent>, (String contactId, DateTime month)>(
  (ref, args) {
    final (contactId, month) = args;
    final all = ref.watch(contactCalendarMonthProvider(month));
    return all.where((e) => e.contact.id == contactId).toList();
  },
);

/// Upcoming recommended calls (all contacts), sorted by date.
final upcomingCallRecommendationsProvider = Provider<List<Contact>>((ref) {
  final contacts = ref.watch(contactsNotifierProvider).value ?? [];
  final today = _dateOnly(DateTime.now());

  final upcoming = contacts
      .map((c) => (contact: c, date: c.nextRecommendedCallAt))
      .where((e) => !e.date.isBefore(today))
      .toList()
    ..sort((a, b) => a.date.compareTo(b.date));

  return upcoming.map((e) => e.contact).toList();
});

DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

bool _sameMonth(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month;