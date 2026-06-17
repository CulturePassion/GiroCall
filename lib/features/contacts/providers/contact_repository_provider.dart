import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase_provider.dart';
import '../../../shared/models/contact.dart';
import '../../../shared/widgets/phone_formatter.dart';

/// Repository for CRUD operations on contacts.
class ContactRepository {
  final SupabaseClient _client;

  const ContactRepository(this._client);

  String? get userId => _client.auth.currentUser?.id;

  String? get _userId => userId;

  Future<List<Contact>> fetchContacts() async {
    final userId = _userId;
    if (userId == null) return [];

    final response = await _client
        .from('contacts')
        .select()
        .eq('user_id', userId)
        .order('name');

    return (response as List)
        .map((json) => Contact.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Stream<List<Contact>> watchContacts() {
    final userId = _userId;
    if (userId == null) return Stream.value([]);

    return _client
        .from('contacts')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .map((rows) {
          final contacts = rows
              .map((json) => Contact.fromJson(json))
              .toList();
          contacts.sort((a, b) => a.name.compareTo(b.name));
          return contacts;
        });
  }

  Future<Contact> addContact(Contact contact) async {
    final userId = _userId;
    if (userId == null) throw Exception('User not authenticated');

    _validateContact(contact);

    final payload = contact.copyWith(userId: userId).toJson();
    final response =
        await _client.from('contacts').insert(payload).select().single();

    return Contact.fromJson(response);
  }

  Future<void> updateContact(Contact contact) async {
    final userId = _userId;
    if (userId == null) throw Exception('User not authenticated');
    if (contact.id == null) throw ArgumentError('Contact id is required');

    _validateContact(contact);

    await _client
        .from('contacts')
        .update(contact.toUpdateJson())
        .eq('id', contact.id!)
        .eq('user_id', userId);
  }

  Future<void> deleteContact(String id) async {
    final userId = _userId;
    if (userId == null) throw Exception('User not authenticated');

    await _client.from('contacts').delete().eq('id', id).eq('user_id', userId);
  }

  Future<Contact?> getContact(String id) async {
    final userId = _userId;
    if (userId == null) return null;

    final response = await _client
        .from('contacts')
        .select()
        .eq('id', id)
        .eq('user_id', userId)
        .maybeSingle();

    if (response == null) return null;
    return Contact.fromJson(response);
  }

  Future<void> upsertContacts(List<Contact> contacts) async {
    final userId = _userId;
    if (userId == null) throw Exception('User not authenticated');

    final payload = contacts.map((c) {
      _validateContact(c);
      return c.copyWith(userId: userId).toJson();
    }).toList();

    await _client.from('contacts').upsert(payload, ignoreDuplicates: true);
  }

  void _validateContact(Contact contact) {
    final name = contact.name.trim();
    if (name.isEmpty) {
      throw ArgumentError('Contact name is required');
    }
    if (!PhoneFormatter.looksValid(contact.phone)) {
      throw ArgumentError('Contact phone number is invalid');
    }
  }
}

final contactRepositoryProvider = Provider<ContactRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return ContactRepository(client);
});
