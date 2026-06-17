import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/presence_status.dart';
import '../../../shared/models/user_status_story.dart';
import '../../contacts/providers/contacts_notifier.dart';
import '../../profile/providers/profile_notifier.dart';
import 'status_repository.dart';

final contactStatusFeedProvider =
    FutureProvider<List<ContactStatusUpdate>>((ref) async {
  final contacts = ref.watch(contactsNotifierProvider).value ?? [];
  if (contacts.isEmpty) return [];
  return ref.watch(statusRepositoryProvider).fetchContactStatuses(contacts);
});

final myPresenceProvider = Provider<({PresenceType? type, String? message})>((ref) {
  final profile = ref.watch(profileNotifierProvider).value;
  if (profile == null) return (type: null, message: null);
  return (
    type: PresenceType.fromValue(profile.presenceType),
    message: profile.presenceMessage,
  );
});