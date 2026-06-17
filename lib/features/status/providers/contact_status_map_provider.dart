import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/presence_status.dart';
import 'status_provider.dart';

/// Maps contact IDs to their active presence type for list avatars.
final contactStatusMapProvider = Provider<Map<String, PresenceType>>((ref) {
  final feed = ref.watch(contactStatusFeedProvider).value ?? [];
  return {
    for (final update in feed) update.contactId: update.statusType,
  };
});
