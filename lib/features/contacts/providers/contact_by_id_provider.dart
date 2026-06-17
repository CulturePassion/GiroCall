import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/contact.dart';
import 'contacts_notifier.dart';

/// Returns a single contact by id, or null if not found.
final contactByIdProvider =
    Provider.family<AsyncValue<Contact?>, String>((ref, id) {
  final async = ref.watch(contactsNotifierProvider);
  return async.whenData((contacts) {
    try {
      return contacts.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  });
});
