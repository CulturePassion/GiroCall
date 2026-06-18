import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/design/colors.dart';
import '../../../core/design/microcopy.dart';
import '../../../core/design/spacing.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/utils/screen_padding.dart';
import '../../../shared/models/contact.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/empty_state.dart';
import '../providers/contacts_notifier.dart';
import '../widgets/contact_detail_pane.dart';
import '../widgets/contact_list_tile.dart';
import '../widgets/contacts_clock_header.dart';

/// People hub — master-detail on wide screens (Apple Contacts style).
class ContactListScreen extends ConsumerStatefulWidget {
  final String? initialContactId;

  const ContactListScreen({super.key, this.initialContactId});

  @override
  ConsumerState<ContactListScreen> createState() => _ContactListScreenState();
}

class _ContactListScreenState extends ConsumerState<ContactListScreen> {
  static const double _listPaneWidth = 360;

  @override
  void initState() {
    super.initState();
    if (widget.initialContactId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(selectedContactIdProvider.notifier).state =
            widget.initialContactId;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final contactsAsync = ref.watch(contactsNotifierProvider);
    final isSplit = ResponsiveLayout.isDesktop(context);
    final selectedId = ref.watch(selectedContactIdProvider);

    return AppScaffold(
      title: 'People',
      showBackButton: false,
      floatingActionButton: isSplit
          ? null
          : FloatingActionButton.extended(
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

          if (isSplit) {
            return _SplitLayout(
              contacts: contacts,
              selectedId: selectedId,
              listWidth: _listPaneWidth,
              onSelect: _selectContact,
              onCall: _callContact,
            );
          }

          return _ContactListOnly(
            contacts: contacts,
            onSelect: (c) => context.push('/contacts/${c.id}'),
            onCall: _callContact,
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: ScreenPadding.all(context),
            child: Text(
              'Something went wrong: $error',
              style: TextStyle(color: AppColors.onSurface(context)),
            ),
          ),
        ),
      ),
    );
  }

  void _selectContact(Contact contact) {
    final id = contact.id;
    if (id == null) return;
    ref.read(selectedContactIdProvider.notifier).state = id;
    context.go('/contacts/$id');
  }

  Future<void> _callContact(Contact contact) async {
    final uri = Uri(scheme: 'tel', path: contact.phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }
}

class _SplitLayout extends StatelessWidget {
  final List<Contact> contacts;
  final String? selectedId;
  final double listWidth;
  final ValueChanged<Contact> onSelect;
  final ValueChanged<Contact> onCall;

  const _SplitLayout({
    required this.contacts,
    required this.selectedId,
    required this.listWidth,
    required this.onSelect,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    final favorites =
        contacts.where((c) => c.isFavorite).toList(growable: false);
    final others =
        contacts.where((c) => !c.isFavorite).toList(growable: false);
    final effectiveId = selectedId ?? contacts.first.id;

    return Padding(
      padding: EdgeInsets.only(
        left: ResponsiveLayout.horizontalPadding(context),
        right: ResponsiveLayout.horizontalPadding(context),
        top: AppSpacing.xs,
        bottom: ScreenPadding.bottomNavClearance(context),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: listWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const ContactsClockHeader(),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Your circle',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Add contact',
                      onPressed: () => context.push('/contacts/add'),
                      icon: const Icon(Icons.person_add_alt_1_outlined),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxs),
                Expanded(
                  child: _ContactListScroll(
                    favorites: favorites,
                    others: others,
                    selectedId: effectiveId,
                    onSelect: onSelect,
                    onCall: onCall,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          VerticalDivider(
            width: 1,
            color: AppColors.isDark(context)
                ? AppColors.darkDivider
                : AppColors.grey200,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: effectiveId == null
                ? const EmptyState(
                    icon: Icons.touch_app_outlined,
                    title: 'Select someone',
                    message: 'Pick a contact from the list to see details.',
                  )
                : ContactDetailPane(
                    key: ValueKey(effectiveId),
                    contactId: effectiveId,
                    onSelectContact: onSelect,
                  ),
          ),
        ],
      ),
    );
  }
}

class _ContactListOnly extends ConsumerWidget {
  final List<Contact> contacts;
  final ValueChanged<Contact> onSelect;
  final ValueChanged<Contact> onCall;

  const _ContactListOnly({
    required this.contacts,
    required this.onSelect,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        padding: ScreenPadding.contactsPane(context).copyWith(
          bottom: ScreenPadding.bottomNavClearance(context) + 72,
        ),
        children: [
          const ContactsClockHeader(),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Your circle',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            'The people you\'re staying connected with.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (favorites.isNotEmpty) ...[
            const _SectionLabel(label: 'Favorites'),
            ...favorites.map(
              (c) => ContactListTile(
                contact: c,
                onTap: () => onSelect(c),
                onCall: () => onCall(c),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
          ],
          if (others.isNotEmpty) ...[
            if (favorites.isNotEmpty) const _SectionLabel(label: 'Everyone'),
            ...others.map(
              (c) => ContactListTile(
                contact: c,
                onTap: () => onSelect(c),
                onCall: () => onCall(c),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ContactListScroll extends ConsumerWidget {
  final List<Contact> favorites;
  final List<Contact> others;
  final String? selectedId;
  final ValueChanged<Contact> onSelect;
  final ValueChanged<Contact> onCall;

  const _ContactListScroll({
    required this.favorites,
    required this.others,
    required this.selectedId,
    required this.onSelect,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      color: AppColors.main,
      onRefresh: () async {
        ref.invalidate(contactsNotifierProvider);
        await ref.read(contactsNotifierProvider.notifier).loadContacts();
      },
      child: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        children: [
          if (favorites.isNotEmpty) ...[
            const _SectionLabel(label: 'Favorites'),
            ...favorites.map(
              (c) => ContactListTile(
                contact: c,
                selected: c.id == selectedId,
                onTap: () => onSelect(c),
                onCall: () => onCall(c),
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
          ],
          if (others.isNotEmpty) ...[
            if (favorites.isNotEmpty) const _SectionLabel(label: 'Everyone'),
            ...others.map(
              (c) => ContactListTile(
                contact: c,
                selected: c.id == selectedId,
                onTap: () => onSelect(c),
                onCall: () => onCall(c),
              ),
            ),
          ],
        ],
      ),
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