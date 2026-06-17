import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase_provider.dart';
import '../../../shared/models/contact.dart';
import '../../../shared/models/presence_status.dart';
import '../../../shared/models/user_status_story.dart';
import '../../../shared/widgets/phone_formatter.dart';

class StatusRepository {
  final SupabaseClient _client;

  const StatusRepository(this._client);

  String? get userId => _client.auth.currentUser?.id;

  Future<void> setPresence({
    required PresenceType type,
    String? message,
    bool postStory = true,
  }) async {
    final uid = userId;
    if (uid == null) throw Exception('User not authenticated');

    final displayMessage = type.displayMessage(message);
    final now = DateTime.now().toUtc();

    await _client.from('user_profiles').update({
      'presence_type': type.value,
      'presence_message': type == PresenceType.custom ? message?.trim() : null,
      'presence_updated_at': now.toIso8601String(),
    }).eq('user_id', uid);

    if (postStory) {
      await _client.from('user_status_stories').insert(
            UserStatusStory(
              id: '',
              userId: uid,
              textContent: displayMessage,
              statusType: type,
              createdAt: now,
              expiresAt: now.add(const Duration(hours: 24)),
            ).toInsertJson(userId: uid, type: type, text: displayMessage),
          );
    }
  }

  Future<List<ContactStatusUpdate>> fetchContactStatuses(
    List<Contact> contacts,
  ) async {
    if (contacts.isEmpty) return [];

    final phones = contacts
        .map((c) => PhoneFormatter.normalize(c.phone))
        .where((p) => p.isNotEmpty)
        .toSet()
        .toList();
    if (phones.isEmpty) return [];

    final profiles = await _client
        .from('user_profiles')
        .select(
          'user_id, display_name, phone, avatar_url, presence_type, '
          'presence_message, presence_updated_at',
        )
        .inFilter('phone', phones)
        .not('presence_type', 'is', null);

    final stories = await _client
        .from('user_status_stories')
        .select()
        .gt('expires_at', DateTime.now().toUtc().toIso8601String())
        .order('created_at', ascending: false);

    final phoneToContact = <String, Contact>{};
    for (final c in contacts) {
      phoneToContact[PhoneFormatter.normalize(c.phone)] = c;
    }

    final updates = <ContactStatusUpdate>[];
    final seenUsers = <String>{};

    for (final row in stories as List) {
      final map = row as Map<String, dynamic>;
      final storyUserId = map['user_id'] as String;
      if (seenUsers.contains(storyUserId)) continue;

      final profile = _findProfileForUser(profiles as List, storyUserId);
      if (profile == null) continue;

      final phone = profile['phone'] as String?;
      if (phone == null) continue;
      final contact = phoneToContact[PhoneFormatter.normalize(phone)];
      if (contact == null) continue;

      final type = PresenceType.fromValue(map['status_type'] as String?) ??
          PresenceType.custom;

      updates.add(ContactStatusUpdate(
        contactId: contact.id!,
        contactName: contact.name,
        contactPhone: contact.phone,
        avatarUrl: profile['avatar_url'] as String?,
        statusType: type,
        message: map['text_content'] as String,
        updatedAt: DateTime.parse(map['created_at'] as String),
        isStory: true,
      ));
      seenUsers.add(storyUserId);
    }

    for (final row in profiles as List) {
      final map = row as Map<String, dynamic>;
      final storyUserId = map['user_id'] as String;
      if (seenUsers.contains(storyUserId)) continue;

      final phone = map['phone'] as String?;
      if (phone == null) continue;
      final contact = phoneToContact[PhoneFormatter.normalize(phone)];
      if (contact == null) continue;

      final updatedAt = map['presence_updated_at'] as String?;
      if (updatedAt == null) continue;
      final updated = DateTime.parse(updatedAt);
      if (DateTime.now().difference(updated).inHours > 24) continue;

      final type = PresenceType.fromValue(map['presence_type'] as String?);
      if (type == null) continue;

      updates.add(ContactStatusUpdate(
        contactId: contact.id!,
        contactName: contact.name,
        contactPhone: contact.phone,
        avatarUrl: map['avatar_url'] as String?,
        statusType: type,
        message: type.displayMessage(map['presence_message'] as String?),
        updatedAt: updated,
      ));
      seenUsers.add(storyUserId);
    }

    updates.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return updates;
  }

  Map<String, dynamic>? _findProfileForUser(List profiles, String userId) {
    for (final row in profiles) {
      final map = row as Map<String, dynamic>;
      if (map['user_id'] == userId) return map;
    }
    return null;
  }
}

final statusRepositoryProvider = Provider<StatusRepository>((ref) {
  return StatusRepository(ref.watch(supabaseClientProvider));
});
