import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/colors.dart';
import '../../../core/design/microcopy.dart';
import '../../../core/design/spacing.dart';
import '../../../core/errors/app_messenger.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/utils/screen_padding.dart';
import '../../../shared/models/contact.dart';
import '../../../shared/models/presence_status.dart';
import '../../../shared/models/user_status_story.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/shell_content.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/page_header.dart';
import '../../profile/providers/profile_notifier.dart';
import '../providers/overdue_contacts_provider.dart';
import '../providers/status_provider.dart';
import '../providers/status_repository.dart';
import '../widgets/status_feed_card.dart';
import '../widgets/status_my_presence_section.dart';
import '../widgets/status_nudge_card.dart';
import '../widgets/status_stories_strip.dart';

class StatusScreen extends ConsumerStatefulWidget {
  const StatusScreen({super.key});

  @override
  ConsumerState<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends ConsumerState<StatusScreen> {
  PresenceType? _selected;
  final _customController = TextEditingController();
  bool _saving = false;
  bool _presenceInitialized = false;

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  Future<void> _savePresence() async {
    final type = _selected;
    if (type == null) return;

    if (type == PresenceType.custom && _customController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a custom status message.')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await ref.read(statusRepositoryProvider).setPresence(
            type: type,
            message: _customController.text,
          );
      ref.invalidate(profileNotifierProvider);
      ref.invalidate(contactStatusFeedProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status set to ${type.label} ✨')),
        );
      }
    } catch (e) {
      if (mounted) AppMessenger.showError(context, e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _onRefresh() async {
    ref.invalidate(contactStatusFeedProvider);
    ref.invalidate(profileNotifierProvider);
    await ref.read(contactStatusFeedProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileNotifierProvider).value;
    final feedAsync = ref.watch(contactStatusFeedProvider);
    final overdue = ref.watch(recommendationsProvider);
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final hPad = ResponsiveLayout.horizontalPadding(context);
    final bottom = ScreenPadding.bottomNavClearance(context);
    final missingPhone = profile != null &&
        (profile.phone == null || profile.phone!.trim().isEmpty);

    ref.listen(myPresenceProvider, (previous, next) {
      if (_presenceInitialized || next.type == null) return;
      setState(() {
        _selected = next.type;
        _customController.text = next.message ?? '';
        _presenceInitialized = true;
      });
    });

    final myPresenceSection = StatusMyPresenceSection(
      profile: profile,
      selected: _selected,
      onSelected: (type) => setState(() => _selected = type),
      customMessageController: _customController,
      saving: _saving,
      missingPhone: missingPhone,
      onSave: _savePresence,
    );

    final feedSection = _StatusFeedSection(
      feedAsync: feedAsync,
      onOpenContact: (id) => context.push('/contacts/$id'),
      onRetry: () => ref.invalidate(contactStatusFeedProvider),
    );

    final nudgesSection = overdue.isEmpty
        ? const SizedBox.shrink()
        : _StatusNudgesSection(
            overdue: overdue.take(5).toList(),
            onOpenContact: (id) => context.push('/contacts/$id'),
            onCall: (id) => context.push('/call/$id'),
          );

    return AppScaffold(
      title: 'Status',
      showBackButton: false,
      body: ShellContent(
        child: RefreshIndicator(
          color: AppColors.main,
          onRefresh: _onRefresh,
          child: isDesktop
              ? Padding(
                  padding:
                      EdgeInsets.fromLTRB(hPad, AppSpacing.xs, hPad, bottom),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final presenceWidth =
                          constraints.maxWidth >= 1000 ? 400.0 : 320.0;
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: presenceWidth,
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: myPresenceSection,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  feedSection,
                                  nudgesSection,
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                )
              : ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding:
                      EdgeInsets.fromLTRB(hPad, AppSpacing.xs, hPad, bottom),
                  children: [
                    myPresenceSection,
                    const SizedBox(height: AppSpacing.lg),
                    feedSection,
                    nudgesSection,
                  ],
                ),
        ),
      ),
    );
  }
}

class _StatusFeedSection extends StatelessWidget {
  final AsyncValue<List<ContactStatusUpdate>> feedAsync;
  final ValueChanged<String> onOpenContact;
  final VoidCallback onRetry;

  const _StatusFeedSection({
    required this.feedAsync,
    required this.onOpenContact,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const PageHeader(title: Microcopy.statusFeedTitle),
        feedAsync.when(
          data: (updates) {
            if (updates.isEmpty) {
              return const EmptyState(
                icon: Icons.circle_outlined,
                title: Microcopy.statusEmptyTitle,
                message: Microcopy.statusEmptyMessage,
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                StatusStoriesStrip(
                  updates: updates,
                  onTap: (update) => onOpenContact(update.contactId),
                ),
                const SizedBox(height: AppSpacing.sm),
                ...updates.map(
                  (update) => StatusFeedCard(
                    update: update,
                    onTap: () => onOpenContact(update.contactId),
                  ),
                ),
              ],
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => ErrorState(
            error: e,
            title: Microcopy.errorLoadStatus,
            onRetry: onRetry,
          ),
        ),
      ],
    );
  }
}

class _StatusNudgesSection extends StatelessWidget {
  final List<Contact> overdue;
  final ValueChanged<String> onOpenContact;
  final ValueChanged<String> onCall;

  const _StatusNudgesSection({
    required this.overdue,
    required this.onOpenContact,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.lg),
        const PageHeader(
          title: Microcopy.statusDueTitle,
          subtitle: Microcopy.statusDueSubtitle,
        ),
        ...overdue.where((c) => c.id != null).map(
              (contact) => StatusNudgeCard(
                contact: contact,
                onTap: () => onOpenContact(contact.id!),
                onCall: () => onCall(contact.id!),
              ),
            ),
      ],
    );
  }
}
