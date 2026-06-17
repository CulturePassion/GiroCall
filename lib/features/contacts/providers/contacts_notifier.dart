import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../core/utils/platform_capabilities.dart';

import '../../../shared/models/contact.dart';
import '../../../shared/models/contact_tag.dart';
import '../services/device_contacts_importer.dart' as device_importer;
import '../services/device_contacts_sync_service.dart' as device_sync;
import 'contact_repository_provider.dart';

/// Active tag filter for the contact list (null = all).
final contactTagFilterProvider = StateProvider<ContactTag?>((ref) => null);

/// Manages the contact list with Supabase realtime sync (all platforms).
class ContactsNotifier extends StateNotifier<AsyncValue<List<Contact>>> {
  final ContactRepository _repository;

  ContactsNotifier(this._repository) : super(const AsyncValue.loading());

  String? get currentUserId => _repository.userId;

  void setContacts(List<Contact> contacts) {
    state = AsyncValue.data(contacts);
  }

  void setError(Object error, StackTrace stackTrace) {
    state = AsyncValue.error(error, stackTrace);
  }

  Future<void> loadContacts() async {
    if (_repository.userId == null) {
      state = const AsyncValue.data([]);
      return;
    }

    state = const AsyncValue.loading();
    try {
      final contacts = await _repository.fetchContacts();
      state = AsyncValue.data(contacts);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addContact(Contact contact) async {
    try {
      final created = await _repository.addContact(contact);
      state = AsyncValue.data([...state.value ?? [], created]);
      await _pushToDeviceIfNeeded(created);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateContact(Contact contact) async {
    try {
      await _repository.updateContact(contact);
      final updated = (state.value ?? []).map((c) {
        return c.id == contact.id ? contact : c;
      }).toList();
      state = AsyncValue.data(updated);
      await _pushToDeviceIfNeeded(contact);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteContact(String id) async {
    try {
      await _repository.deleteContact(id);
      final updated = (state.value ?? []).where((c) => c.id != id).toList();
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Imports device contacts on iOS/Android. Not available on web.
  Future<int> importDeviceContacts() async {
    if (kIsWeb || !supportsDeviceContactImport) {
      throw UnsupportedError(
        'Device contact import is not supported on web. '
        'Add contacts manually — they sync across all your devices.',
      );
    }

    final userId = _repository.userId;
    if (userId == null) throw Exception('User not authenticated');

    final imported = await device_importer.importDeviceContacts(userId: userId);
    if (imported.isEmpty) {
      throw Exception('No contacts with valid phone numbers were found.');
    }

    await _repository.upsertContacts(imported);
    await loadContacts();
    return imported.length;
  }

  /// Bidirectional sync with the device address book (mobile only).
  Future<int> syncDeviceContacts() async {
    if (kIsWeb || !device_sync.supportsDeviceContactSync) {
      throw UnsupportedError(
        'Device contact sync is not supported on this platform.',
      );
    }

    final userId = _repository.userId;
    if (userId == null) throw Exception('User not authenticated');

    final existing = state.value ?? [];
    final count = await device_sync.syncContactsBidirectional(
      userId: userId,
      existing: existing,
    );
    await loadContacts();
    return count;
  }

  Future<void> _pushToDeviceIfNeeded(Contact contact) async {
    if (!device_sync.supportsDeviceContactSync || !contact.syncToDevice) {
      return;
    }
    try {
      await device_sync.pushContactToDevice(contact);
    } catch (e, st) {
      debugPrint('Device contact push failed: $e\n$st');
    }
  }

  Contact? getById(String id) {
    for (final contact in state.value ?? const <Contact>[]) {
      if (contact.id == id) return contact;
    }
    return null;
  }
}

/// Sorted contacts for UI display.
final sortedContactsProvider = Provider<AsyncValue<List<Contact>>>((ref) {
  return ref.watch(contactsNotifierProvider);
});

/// Contacts filtered by the selected relationship tag.
final filteredContactsProvider = Provider<AsyncValue<List<Contact>>>((ref) {
  final contactsAsync = ref.watch(sortedContactsProvider);
  final filter = ref.watch(contactTagFilterProvider);

  return contactsAsync.when(
    data: (contacts) {
      if (filter == null) return AsyncValue.data(contacts);
      return AsyncValue.data(
        contacts.where((c) => c.tag == filter).toList(growable: false),
      );
    },
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
  );
});

/// Contacts that are overdue for a call.
final overdueContactsProvider = Provider<List<Contact>>((ref) {
  final async = ref.watch(contactsNotifierProvider);
  return async.value?.where((c) => c.isOverdue).toList() ?? [];
});

final contactsNotifierProvider =
    StateNotifierProvider<ContactsNotifier, AsyncValue<List<Contact>>>((ref) {
  final repo = ref.watch(contactRepositoryProvider);
  final notifier = ContactsNotifier(repo);

  if (repo.userId != null) {
    unawaited(notifier.loadContacts());
  } else {
    notifier.setContacts([]);
  }

  final subscription = repo.watchContacts().listen(
        notifier.setContacts,
        onError: notifier.setError,
      );
  ref.onDispose(subscription.cancel);

  return notifier;
});
