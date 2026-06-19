import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/colors.dart';
import '../../../core/utils/platform_capabilities.dart';
import '../../../core/errors/app_messenger.dart';
import '../providers/contacts_notifier.dart';

class ImportContactsScreen extends ConsumerStatefulWidget {
  const ImportContactsScreen({super.key});

  @override
  ConsumerState<ImportContactsScreen> createState() =>
      _ImportContactsScreenState();
}

class _ImportContactsScreenState extends ConsumerState<ImportContactsScreen> {
  bool _importing = false;

  Future<void> _import() async {
    setState(() => _importing = true);
    try {
      final count = await ref
          .read(contactsNotifierProvider.notifier)
          .importDeviceContacts();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            count > 0
                ? 'Imported $count contact${count == 1 ? '' : 's'}'
                : 'No new contacts to import',
          ),
        ),
      );
      if (count > 0) context.pop();
    } catch (e) {
      if (!mounted) return;
      AppMessenger.showError(context, e);
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceImport = supportsDeviceContactImport;

    return Scaffold(
      appBar: AppBar(title: const Text('Import contacts')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              deviceImport
                  ? Icons.contacts_outlined
                  : Icons.cloud_sync_outlined,
              size: 64,
              color: AppColors.vibrantGreen,
            ),
            const SizedBox(height: 16),
            Text(
              deviceImport
                  ? 'Import from your phone'
                  : 'Contacts sync across your devices',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              deviceImport
                  ? 'GiroCall only reads names and phone numbers you choose to '
                      'import. We never upload your full address book without '
                      'your permission.'
                  : 'On web, import from your phone address book is not available. '
                      'Add contacts manually here — they sync securely to your '
                      'account and appear on iOS and Android too.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 24),
            if (deviceImport) ...[
              FilledButton.icon(
                onPressed: _importing ? null : _import,
                icon: _importing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.download),
                label:
                    Text(_importing ? 'Importing…' : 'Allow access & import'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => context.push('/contacts/add'),
                icon: const Icon(Icons.person_add_outlined),
                label: const Text('Add manually instead'),
              ),
            ] else ...[
              FilledButton.icon(
                onPressed: () => context.push('/contacts/add'),
                icon: const Icon(Icons.person_add_outlined),
                label: const Text('Add a contact'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to contacts'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
