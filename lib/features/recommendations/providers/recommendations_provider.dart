import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/contact.dart';
import '../../contacts/providers/contacts_notifier.dart';

/// Generates a smart "Call Again" list sorted by urgency.
///
/// Urgency score combines days overdue and relationship score boost.
final recommendationsProvider = Provider<List<Contact>>((ref) {
  final async = ref.watch(contactsNotifierProvider);
  final contacts = async.value ?? [];

  final candidates = contacts.where((contact) => contact.isOverdue).toList();
  if (candidates.isEmpty) return [];

  final scored = candidates.map((contact) {
    final daysSince = contact.daysSinceLastCall ?? contact.targetFrequencyDays;
    final overdue = daysSince - contact.targetFrequencyDays;
    final relationshipBoost =
        (5 - (contact.relationshipScore ?? 3)).clamp(0, 4);
    final urgency = overdue + relationshipBoost * 5;
    return _ScoredContact(contact: contact, urgency: urgency);
  }).toList();

  scored.sort((a, b) => b.urgency.compareTo(a.urgency));
  return scored.map((s) => s.contact).toList();
});

class _ScoredContact {
  final Contact contact;
  final int urgency;

  _ScoredContact({required this.contact, required this.urgency});
}
