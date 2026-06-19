import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/contact.dart';
import 'calendar_sync_service_mobile.dart'
    if (dart.library.html) 'calendar_sync_service_web.dart' as impl;

/// Syncs recommended calls to device calendar (mobile) or ICS export (web).
abstract class CalendarSyncService {
  Future<bool> syncRecommendations(List<Contact> contacts);
  Future<bool> addSingleRecommendation(Contact contact);
}

final calendarSyncServiceProvider = Provider<CalendarSyncService>(
  (ref) => impl.createCalendarSyncService(),
);
