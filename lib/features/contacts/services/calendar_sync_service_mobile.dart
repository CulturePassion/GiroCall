import 'package:add_2_calendar/add_2_calendar.dart';

import '../../../shared/models/contact.dart';
import 'calendar_sync_service.dart';

CalendarSyncService createCalendarSyncService() => MobileCalendarSyncService();

/// Adds call reminders to the device calendar (syncs via iOS/Android to Outlook, etc.).
class MobileCalendarSyncService implements CalendarSyncService {
  @override
  Future<bool> addSingleRecommendation(Contact contact) async {
    return syncRecommendations([contact]);
  }

  @override
  Future<bool> syncRecommendations(List<Contact> contacts) async {
    if (contacts.isEmpty) return false;

    var added = 0;
    for (final contact in contacts) {
      final when = contact.nextRecommendedCallAt;
      final start = DateTime(when.year, when.month, when.day, 9);
      final end = start.add(const Duration(minutes: 30));

      final event = Event(
        title: 'Call ${contact.name}',
        description:
            'GiroCall reminder — stay connected with ${contact.name}.',
        location: contact.phone,
        startDate: start,
        endDate: end,
        iosParams: const IOSParams(reminder: Duration(hours: 1)),
        androidParams: const AndroidParams(
          emailInvites: [],
        ),
      );

      try {
        final ok = await Add2Calendar.addEvent2Cal(event);
        if (ok) added += 1;
      } catch (_) {
        // Continue with remaining contacts.
      }
    }

    return added > 0;
  }
}