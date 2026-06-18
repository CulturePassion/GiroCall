import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logging/logging.dart';

import '../../../core/supabase_provider.dart';
import '../../../shared/models/contact.dart';
import '../../../shared/widgets/phone_formatter.dart';

// Logger for debugging purposes
final _log = Logger('ContactRepository');

/// Repository for CRUD operations on contacts.
class ContactRepository {
  final SupabaseClient _client;

  const ContactRepository(this._client);

  String? get userId => _client.auth.currentUser?.id;

  Future<List<Contact>> fetchContacts() async {
    _log.fine('Fetching contacts for user');
    
    final userId = this.userId;
    if (userId == null) {
      _log.warning('User not authenticated');
      return [];
    }

    try {
      final response = await _client
          .from('contacts')
          .select()
          .eq('user_id', userId)
          .order('name');

      _log.fine('Fetched ${response.length} contacts');
      
      return List<Map<String, dynamic>>.from(response)
          .map((json) => Contact.fromJson(json))
          .toList();
    } catch (e, stackTrace) {
      _log.severe('Error fetching contacts: $e', stackTrace);
      rethrow;
    }
  }

  Stream<List<Contact>> watchContacts() {
    _log.fine('Watching contacts for user');
    
    final userId = this.userId;
    if (userId == null) {
      _log.warning('User not authenticated');
      return Stream.value([]);
    }

    try {
      return _client
          .from('contacts')
          .stream(primaryKey: ['id'])
          .eq('user_id', userId)
          .map((rows) {
            final contacts = rows.map((json) => Contact.fromJson(json)).toList();
            contacts.sort((a, b) => a.name.compareTo(b.name));
            _log.fine('Stream updated with ${contacts.length} contacts');
            return contacts;
          });
    } catch (e, stackTrace) {
      _log.severe('Error watching contacts: $e', stackTrace);
      rethrow;
    }
  }

  Future<Contact> addContact(Contact contact) async {
    _log.fine('Adding new contact: ${contact.name}');
    
    final userId = this.userId;
    if (userId == null) {
      _log.severe('User not authenticated');
      throw Exception('User not authenticated');
    }

    try {
      _validateContact(contact);

      final payload = contact.copyWith(userId: userId).toJson();
      final response =
          await _client.from('contacts').insert(payload).select().single();

      _log.info('Contact added successfully: ${contact.name}');
      return Contact.fromJson(response);
    } catch (e, stackTrace) {
      _log.severe('Error adding contact: $e', stackTrace);
      rethrow;
    }
  }

  Future<void> updateContact(Contact contact) async {
    _log.fine('Updating contact: ${contact.id}');
    
    final userId = this.userId;
    if (userId == null) {
      _log.severe('User not authenticated');
      throw Exception('User not authenticated');
    }
    if (contact.id == null) {
      _log.severe('Contact id is required');
      throw ArgumentError('Contact id is required');
    }

    try {
      _validateContact(contact);

      await _client
          .from('contacts')
          .update(contact.toUpdateJson())
          .eq('id', contact.id!)
          .eq('user_id', userId);
          
      _log.info('Contact updated successfully: ${contact.id}');
    } catch (e, stackTrace) {
      _log.severe('Error updating contact: $e', stackTrace);
      rethrow;
    }
  }

  Future<void> deleteContact(String id) async {
    _log.fine('Deleting contact: $id');
    
    final userId = this.userId;
    if (userId == null) {
      _log.severe('User not authenticated');
      throw Exception('User not authenticated');
    }

    try {
      await _client.from('contacts').delete().eq('id', id).eq('user_id', userId);
      _log.info('Contact deleted successfully: $id');
    } catch (e, stackTrace) {
      _log.severe('Error deleting contact: $e', stackTrace);
      rethrow;
    }
  }

  Future<Contact?> getContact(String id) async {
    _log.fine('Getting contact: $id');
    
    final userId = this.userId;
    if (userId == null) {
      _log.warning('User not authenticated');
      return null;
    }

    try {
      final response = await _client
          .from('contacts')
          .select()
          .eq('id', id)
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) {
        _log.fine('Contact not found: $id');
        return null;
      }
      
      _log.fine('Contact found: $id');
      return Contact.fromJson(response);
    } catch (e, stackTrace) {
      _log.severe('Error getting contact: $e', stackTrace);
      rethrow;
    }
  }

  Future<void> upsertContacts(List<Contact> contacts) async {
    _log.fine('Upserting ${contacts.length} contacts');
    
    final userId = this.userId;
    if (userId == null) {
      _log.severe('User not authenticated');
      throw Exception('User not authenticated');
    }

    if (contacts.isEmpty) {
      _log.fine('No contacts to upsert');
      return;
    }

    try {
      final payload = contacts.map((c) {
        _validateContact(c);
        return c.copyWith(userId: userId).toJson();
      }).toList();

      await _client.from('contacts').upsert(payload, ignoreDuplicates: true);
      _log.info('Successfully upserted ${contacts.length} contacts');
    } catch (e, stackTrace) {
      _log.severe('Error upserting contacts: $e', stackTrace);
      rethrow;
    }
  }

  void _validateContact(Contact contact) {
    _log.fine('Validating contact: ${contact.name}');
    
    final name = contact.name.trim();
    if (name.isEmpty) {
      _log.warning('Contact name is required');
      throw ArgumentError('Contact name is required');
    }
    
    if (!PhoneFormatter.looksValid(contact.phone)) {
      _log.warning('Contact phone number is invalid: ${contact.phone}');
      throw ArgumentError('Contact phone number is invalid');
    }
    
    _log.fine('Contact validated successfully: ${contact.name}');
  }
}

final contactRepositoryProvider = Provider<ContactRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return ContactRepository(client);
});
