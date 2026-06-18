import 'dart:convert';

import 'package:share_plus/share_plus.dart';

import '../../../shared/models/contact.dart';
import 'calendar_sync_service.dart';

CalendarSyncService createCalendarSyncService() => WebCalendarSyncService();

/// Exports recommended calls as ICS for Outlook / Google Calendar import.
class WebCalendarSyncService implements CalendarSyncService {
  @override
  Future<bool> addSingleRecommendation(Contact contact) async {
    return syncRecommendations([contact]);
  }

  @override
  Future<bool> syncRecommendations(List<Contact> contacts) async {
    if (contacts.isEmpty) return false;

    final ics = _buildIcs(contacts);
    try {
      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile.fromData(
              utf8.encode(ics),
              name: 'girocall-recommendations.ics',
              mimeType: 'text/calendar',
            ),
          ],
          subject: 'GiroCall — upcoming call reminders',
          text:
              'Import this calendar file into Outlook, Google Calendar, or Apple Calendar.',
        ),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  String _buildIcs(List<Contact> contacts) {
    final buffer = StringBuffer()
      ..writeln('BEGIN:VCALENDAR')
      ..writeln('VERSION:2.0')
      ..writeln('PRODID:-//GiroCall//Call Reminders//EN')
      ..writeln('CALSCALE:GREGORIAN');

    for (final contact in contacts) {
      final start = contact.nextRecommendedCallAt;
      final startUtc = DateTime(start.year, start.month, start.day, 14);
      final endUtc = startUtc.add(const Duration(minutes: 30));
      final uid =
          'girocall-${contact.id}-${start.millisecondsSinceEpoch}@girocall.com';

      buffer
        ..writeln('BEGIN:VEVENT')
        ..writeln('UID:$uid')
        ..writeln('DTSTAMP:${_icsDate(DateTime.now().toUtc())}')
        ..writeln('DTSTART:${_icsDate(startUtc.toUtc())}')
        ..writeln('DTEND:${_icsDate(endUtc.toUtc())}')
        ..writeln('SUMMARY:Call ${_escape(contact.name)}')
        ..writeln(
          'DESCRIPTION:GiroCall reminder — reconnect with ${_escape(contact.name)}',
        )
        ..writeln('END:VEVENT');
    }

    buffer.writeln('END:VCALENDAR');
    return buffer.toString();
  }

  String _icsDate(DateTime utc) {
    final y = utc.year.toString().padLeft(4, '0');
    final m = utc.month.toString().padLeft(2, '0');
    final d = utc.day.toString().padLeft(2, '0');
    final h = utc.hour.toString().padLeft(2, '0');
    final min = utc.minute.toString().padLeft(2, '0');
    final s = utc.second.toString().padLeft(2, '0');
    return '$y$m$d' 'T$h$min$s' 'Z';
  }

  String _escape(String value) =>
      value.replaceAll('\\', '\\\\').replaceAll(',', '\\,');
}