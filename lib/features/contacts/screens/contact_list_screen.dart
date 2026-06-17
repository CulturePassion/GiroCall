import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/sync/sync_service.dart';
import '../../../core/utils/screen_padding.dart';
import '../../../core/utils/platform_capabilities.dart';
import '../../../core/utils/supabase_error_message.dart';
import '../../../shared/models/contact_tag.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/contact_tag_chip.dart';
import '../../../shared/widgets/empty_state.dart';
import '../providers/contacts_notifier.dart';
import '../services/device_contacts_sync_service.dart';
import '../widgets/contact_list_tile.dart';

class ContactListScreen extends ConsumerStatefulWidget {
  const ContactListScreen({super.key});

  @override
  ConsumerState<ContactListScreen> createState() => _ContactListScreenState();
}

class _ContactListScreenState extends ConsumerState<ContactListScreen> {
  bool _syncing = false;

  Future<void> _syncDeviceContacts() async {
    setState(() => _syncing = true);
    try {
      final count = await ref
          .read(contactsNotifierProvider.notifier)
          .syncDeviceContacts();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            count > 0
                ? 'Synced $count contact${count == 1 ? '' : 's'} with your phone'
                : 'Contacts are up to date',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(supabaseErrorMessage(e))),
      );
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final contactsAsync = ref.watch(filteredContactsProvider);
    final selectedTag = ref.watch(contactTagFilterProvider);

    return AppScaffold(
      title: 'Your People',
      showBackButton: false,
      actions: [
        if (supportsDeviceContactSync)
          IconButton(
            icon: _syncing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.sync),
            tooltip: 'Sync with phone contacts',
            onPressed: _syncing ? null : _syncDeviceContacts,
          ),
        if (supportsDeviceContactImport)
          IconButton(
            icon: const Icon(Icons.download_outlined),
            tooltip: 'Import contacts',
            onPressed: () => context.push('/contacts/import'),
          ),
        IconButton(
          icon: const Icon(Icons.qr_code_scanner),
          tooltip: 'Scan QR code',
          onPressed: () => context.push('/contacts/scan'),
        ),
      ],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/contacts/add'),
        icon: const Icon(Icons.person_add),
        label: const Text('Add'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                ContactTagChip(
                  selected: selectedTag == null,
                  onTap: () =>
                      ref.read(contactTagFilterProvider.notifier).state = null,
                ),
                const SizedBox(width: 8),
                ...ContactTag.values.map(
                  (tag) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ContactTagChip(
                      tag: tag,
                      selected: selectedTag == tag,
                      onTap: () => ref
                          .read(contactTagFilterProvider.notifier)
                          .state = tag,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: contactsAsync.when(
              data: (contacts) {
                if (contacts.isEmpty) {
                  final deviceImport = supportsDeviceContactImport;
                  final hasFilter = selectedTag != null;
                  return RefreshIndicator(
                    onRefresh: () =>
                        ref.read(syncServiceProvider).refreshAll(ref),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.5,
                          child: EmptyState(
                            icon: Icons.people_outline,
                            title: hasFilter
                                ? 'No ${selectedTag.label.toLowerCase()} contacts'
                                : 'No contacts yet',
                            message: hasFilter
                                ? 'Try another tag or add someone to this group.'
                                : deviceImport
                                    ? 'Import from your device, scan a QR code, or add manually.'
                                    : 'Add someone manually — contacts sync across all devices.',
                            actionLabel: hasFilter
                                ? 'Add a contact'
                                : deviceImport
                                    ? 'Import contacts'
                                    : 'Add a contact',
                            onAction: () => hasFilter || !deviceImport
                                ? context.push('/contacts/add')
                                : context.push('/contacts/import'),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () =>
                      ref.read(syncServiceProvider).refreshAll(ref),
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      16,
                      8,
                      16,
                      ScreenPadding.bottomNavClearance(context) + 56,
                    ),
                    itemCount: contacts.length,
                    itemBuilder: (context, index) {
                      final contact = contacts[index];
                      return ContactListTile(
                        contact: contact,
                        onTap: () => context.push('/contacts/${contact.id}'),
                        onCall: () => context.push('/call/${contact.id}'),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(supabaseErrorMessage(error)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
