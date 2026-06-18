import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/design/colors.dart';
import '../../../core/design/spacing.dart';
import '../../../core/design/tokens.dart';
import '../../../core/design/microcopy.dart';
import '../../../core/utils/screen_padding.dart';
import '../../../core/utils/supabase_error_message.dart';
import '../../../shared/models/presence_status.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/page_header.dart';
import '../../../shared/widgets/premium_card.dart';
import '../../profile/providers/profile_notifier.dart';
import '../providers/overdue_contacts_provider.dart';
import '../providers/status_provider.dart';
import '../providers/status_repository.dart';
import '../widgets/presence_selector.dart';
import '../widgets/status_avatar.dart';

class StatusScreen extends ConsumerStatefulWidget {
  const StatusScreen({super.key});

  @override
  ConsumerState<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends ConsumerState<StatusScreen> {
  PresenceType? _selected;
  final _customController = TextEditingController();
  bool _saving = false;

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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(supabaseErrorMessage(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final myPresence = ref.read(myPresenceProvider);
      if (myPresence.type != null && mounted) {
        setState(() {
          _selected = myPresence.type;
          _customController.text = myPresence.message ?? '';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileNotifierProvider).value;
    final feedAsync = ref.watch(contactStatusFeedProvider);
    final overdue = ref.watch(recommendationsProvider);
    final timeFormat = DateFormat.jm();
    final missingPhone = profile != null &&
        (profile.phone == null || profile.phone!.trim().isEmpty);

    return AppScaffold(
      title: 'Status',
      showBackButton: false,
      body: RefreshIndicator(
        color: AppColors.main,
        onRefresh: () async {
          ref.invalidate(contactStatusFeedProvider);
          await ref.read(contactStatusFeedProvider.future);
        },
        child: ListView(
          padding: ScreenPadding.all(context).copyWith(
            bottom: ScreenPadding.bottomNavClearance(context),
          ),
          children: [
            const PageHeader(
              title: Microcopy.statusMyTitle,
              subtitle: Microcopy.statusMySubtitle,
            ),
            if (missingPhone)
              PremiumCard(
                accentColor: AppColors.orange,
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.orange),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        'Add your phone number in Profile → Edit so friends can see your status.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            if (missingPhone) const SizedBox(height: AppSpacing.sm),
            PremiumCard(
              child: PresenceSelector(
                selected: _selected,
                onSelected: (type) => setState(() => _selected = type),
                customMessageController: _customController,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, AppTokens.minTouchTarget),
              ),
              onPressed: _saving || _selected == null ? null : _savePresence,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check),
              label: Text(_saving ? 'Saving…' : 'Update my status'),
            ),
            const SizedBox(height: AppSpacing.lg),
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
                  children: updates.map((update) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
                      child: PremiumCard(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs,
                          vertical: AppSpacing.xxs,
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: StatusAvatar(
                            initials: update.contactName.isNotEmpty
                                ? update.contactName[0].toUpperCase()
                                : '?',
                            statusType: update.statusType,
                            imageUrl: update.avatarUrl,
                          ),
                          title: Text(
                            update.contactName,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(update.message),
                          trailing: Text(
                            timeFormat.format(update.updatedAt.toLocal()),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          onTap: () =>
                              context.push('/contacts/${update.contactId}'),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text(supabaseErrorMessage(e)),
            ),
            if (overdue.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              const PageHeader(
                title: Microcopy.statusDueTitle,
                subtitle: Microcopy.statusDueSubtitle,
              ),
              ...overdue.take(5).map(
                    (contact) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
                      child: PremiumCard(
                        accentColor: AppColors.orange,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs,
                          vertical: AppSpacing.xxs,
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: StatusAvatar(initials: contact.initials),
                          title: Text(
                            contact.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            contact.daysSinceLastCall == null
                                ? 'Never called — they\'d love to hear from you'
                                : '${contact.daysSinceLastCall} days since last call',
                          ),
                          trailing: IconButton(
                            tooltip: 'Call ${contact.name}',
                            icon: const Icon(
                              Icons.phone,
                              color: AppColors.main,
                            ),
                            onPressed: () =>
                                context.push('/call/${contact.id}'),
                          ),
                          onTap: () => context.push('/contacts/${contact.id}'),
                        ),
                      ),
                    ),
                  ),
            ],
          ],
        ),
      ),
    );
  }
}
