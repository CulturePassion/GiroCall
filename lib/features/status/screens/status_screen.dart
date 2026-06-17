import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/app_colors.dart';
import '../../../core/utils/screen_padding.dart';
import '../../../core/utils/supabase_error_message.dart';
import '../../../shared/models/presence_status.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../profile/providers/profile_notifier.dart';
import '../../recommendations/providers/recommendations_provider.dart';
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

    if (type == PresenceType.custom &&
        _customController.text.trim().isEmpty) {
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
          SnackBar(content: Text('Status set to ${type.label}')),
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
    final missingPhone =
        profile != null && (profile.phone == null || profile.phone!.trim().isEmpty);

    return AppScaffold(
      title: 'Status',
      showBackButton: false,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(contactStatusFeedProvider);
          await ref.read(contactStatusFeedProvider.future);
        },
        child: ListView(
          padding: ScreenPadding.all(context).copyWith(
            bottom: ScreenPadding.bottomNavClearance(context),
          ),
          children: [
            Text(
              'My status',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Let your GiroCall contacts know when you\'re free to chat.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            if (missingPhone)
              Card(
                color: AppColors.accentCoral.withValues(alpha: 0.12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.accentCoral),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Add your phone number in Profile → Edit so contacts can see your status.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            PresenceSelector(
              selected: _selected,
              onSelected: (type) => setState(() => _selected = type),
              customMessageController: _customController,
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _saving || _selected == null ? null : _savePresence,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check),
              label: Text(_saving ? 'Saving…' : 'Update my status'),
            ),
            const SizedBox(height: 32),
            Text(
              'Recent updates',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            feedAsync.when(
              data: (updates) {
                if (updates.isEmpty) {
                  return const EmptyState(
                    icon: Icons.circle_outlined,
                    title: 'No updates yet',
                    message:
                        'When your contacts set a status on GiroCall, you\'ll see it here.',
                  );
                }
                return Column(
                  children: updates.map((update) {
                    return Card(
                      child: ListTile(
                        leading: StatusAvatar(
                          initials: update.contactName.isNotEmpty
                              ? update.contactName[0].toUpperCase()
                              : '?',
                          statusType: update.statusType,
                          imageUrl: update.avatarUrl,
                        ),
                        title: Text(update.contactName),
                        subtitle: Text(update.message),
                        trailing: Text(
                          timeFormat.format(update.updatedAt.toLocal()),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        onTap: () =>
                            context.push('/contacts/${update.contactId}'),
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text(supabaseErrorMessage(e)),
            ),
            if (overdue.isNotEmpty) ...[
              const SizedBox(height: 32),
              Text(
                'Due for a call',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'People you haven\'t reached in a while.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 12),
              ...overdue.take(5).map(
                    (contact) => Card(
                      child: ListTile(
                        leading: StatusAvatar(initials: contact.initials),
                        title: Text(contact.name),
                        subtitle: Text(
                          contact.daysSinceLastCall == null
                              ? 'Never called'
                              : '${contact.daysSinceLastCall} days since last call',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.phone, color: AppColors.primaryTeal),
                          onPressed: () => context.push('/call/${contact.id}'),
                        ),
                        onTap: () => context.push('/contacts/${contact.id}'),
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