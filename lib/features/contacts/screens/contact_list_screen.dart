import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/design/colors.dart';
import '../../../core/design/microcopy.dart';
import '../../../core/design/spacing.dart';
import '../../../core/utils/screen_padding.dart';
import '../../../shared/models/contact.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/page_header.dart';
import '../providers/contacts_notifier.dart';
import '../widgets/contact_list_tile.dart';

class ContactListScreen extends ConsumerWidget {
  const ContactListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactsAsync = ref.watch(contactsNotifierProvider);

    return AppScaffold(
      title: 'People',
      showBackButton: false,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/contacts/add'),
        icon: const Icon(Icons.person_add_alt_1_outlined),
        label: const Text('Add'),
      ),
      body: contactsAsync.when(
        data: (contacts) {
          if (contacts.isEmpty) {
            return EmptyState(
              icon: Icons.favorite_border,
              title: Microcopy.contactsEmptyTitle,
              message: Microcopy.contactsEmptyMessage,
              actionLabel: Microcopy.contactsAddCta,
              onAction: () => context.push('/contacts/add'),
            );
          }

          final favorites =
              contacts.where((c) => c.isFavorite).toList(growable: false);
          final others =
              contacts.where((c) => !c.isFavorite).toList(growable: false);

          return RefreshIndicator(
            color: AppColors.main,
            onRefresh: () async {
              ref.invalidate(contactsNotifierProvider);
              await ref.read(contactsNotifierProvider.notifier).loadContacts();
            },
            child: ListView(
              padding: ScreenPadding.all(context).copyWith(
                bottom: ScreenPadding.bottomNavClearance(context) + 72,
              ),
              children: [
                const PageHeader(
                  title: 'Your circle',
                  subtitle: 'The people you\'re staying connected with.',
                ),
                if (favorites.isNotEmpty) ...[
                  const _SectionLabel(label: 'Favorites'),
                  ...favorites.map(
                    (c) => _ContactRow(
                      contact: c,
                      onTap: () => context.push('/contacts/${c.id}'),
                      onCall: () => _callContact(c),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
                if (others.isNotEmpty) ...[
                  if (favorites.isNotEmpty)
                    const _SectionLabel(label: 'Everyone'),
                  ...others.map(
                    (c) => _ContactRow(
                      contact: c,
                      onTap: () => context.push('/contacts/${c.id}'),
                      onCall: () => _callContact(c),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(
              'Something went wrong: $error',
              style: TextStyle(color: AppColors.onSurface(context)),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _callContact(Contact contact) async {
    final uri = Uri(scheme: 'tel', path: contact.phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

class _ContactRow extends StatelessWidget {
  final Contact contact;
  final VoidCallback onTap;
  final VoidCallback onCall;

  const _ContactRow({
    required this.contact,
    required this.onTap,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    return ContactListTile(
      contact: contact,
      onTap: onTap,
      onCall: onCall,
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.main,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
      ),
    );
  }
}