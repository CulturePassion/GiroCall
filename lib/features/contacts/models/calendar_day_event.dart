import 'package:flutter/foundation.dart';

import '../../../shared/models/contact.dart';

enum CalendarEventKind { pastCall, recommendedCall }

@immutable
class CalendarDayEvent {
  const CalendarDayEvent({
    required this.date,
    required this.kind,
    required this.contact,
    this.rating,
    this.logId,
  });

  final DateTime date;
  final CalendarEventKind kind;
  final Contact contact;
  final int? rating;
  final String? logId;

  bool get isPastCall => kind == CalendarEventKind.pastCall;
  bool get isRecommended => kind == CalendarEventKind.recommendedCall;
}
