import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/app_colors.dart';
import '../../../shared/models/contact.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../status/widgets/status_avatar.dart';
import '../providers/contact_by_id_provider.dart';
import '../providers/contacts_notifier.dart';

class ContactDetailScreen extends ConsumerWidget {
  final String contactId;

  const ContactDetailScreen({
    super.key,
    required this.contactId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactAsync = ref.watch(contactByIdProvider(contactId));

    return contactAsync.when(
      data: (contact) {
        if (contact == null) {
          return const AppScaffold(
            title: 'Contact',
            body: Center(child: Text('Contact not found.')),
          );
        }
        return _buildBody(context, ref, contact);
      },
      loading: () => const AppScaffold(
        title: 'Contact',
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => AppScaffold(
        title: 'Contact',
        body: Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, Contact contact) {
    final birthdayFormat = DateFormat.yMMMMd();

    return AppScaffold(
      title: contact.name,
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_outlined),
          onPressed: () => context.push('/contacts/$contactId/edit'),
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Delete contact?'),
                content: Text('Remove ${contact.name} from GiroCall?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text(
                      'Delete',
                      style: TextStyle(color: AppColors.error),
                    ),
                  ),
                ],
              ),
            );

            if (confirmed == true) {
              await ref
                  .read(contactsNotifierProvider.notifier)
                  .deleteContact(contactId);
              if (context.mounted) context.pop();
            }
          },
        ),
      ],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: StatusAvatar(
                initials: contact.initials,
                imageUrl: contact.photoUrl,
                radius: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              contact.name,
              style: Theme.of(context).textTheme.displaySmall,
              textAlign: TextAlign.center,
            ),
            if (contact.jobTitle?.isNotEmpty == true ||
                contact.company?.isNotEmpty == true)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  [
                    if (contact.jobTitle?.isNotEmpty == true) contact.jobTitle!,
                    if (contact.company?.isNotEmpty == true) contact.company!,
                  ].join(' · '),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 8),
            Text(
              contact.phone,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            if (contact.secondaryPhone?.isNotEmpty == true) ...[
              const SizedBox(height: 4),
              Text(
                contact.secondaryPhone!,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 32),
            _InfoRow(
                label: 'Call frequency',
                value: 'Every ${contact.targetFrequencyDays} days'),
            if (contact.email?.isNotEmpty == true)
              _InfoRow(label: 'Email', value: contact.email!),
            if (contact.website?.isNotEmpty == true)
              _InfoRow(label: 'Website', value: contact.website!),
            if (contact.birthday != null)
              _InfoRow(
                label: 'Birthday',
                value: birthdayFormat.format(contact.birthday!),
              ),
            if (contact.formattedAddress != null)
              _InfoRow(label: 'Address', value: contact.formattedAddress!),
            if (contact.notes?.isNotEmpty == true)
              _InfoRow(label: 'Notes', value: contact.notes!),
            if (contact.syncToDevice)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Icon(Icons.sync, size: 16, color: AppColors.primaryTeal),
                    SizedBox(width: 8),
                    Text('Synced to phone contacts'),
                  ],
                ),
              ),
            const SizedBox(height: 32),
            PrimaryButton(
              label: 'Call now',
              icon: Icons.phone,
              onPressed: () => context.push('/call/${contact.id}'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}
