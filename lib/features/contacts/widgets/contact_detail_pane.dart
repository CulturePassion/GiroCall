import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/design/colors.dart';
import '../../../core/design/microcopy.dart';
import '../../../core/design/spacing.dart';
import '../../../core/design/tokens.dart';
import '../../../core/extensions/date_time_extensions.dart';
import '../../../shared/models/call_log.dart';
import '../../../shared/models/contact.dart';
import '../../../core/errors/app_messenger.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/premium_card.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/star_rating.dart';
import '../../call_log/providers/call_log_notifier.dart';
import '../../status/providers/contact_status_map_provider.dart';
import '../../status/widgets/status_avatar.dart';
import '../providers/contact_by_id_provider.dart';
import '../providers/contacts_notifier.dart';
import 'contacts_calendar_panel.dart';

/// Right pane — contact profile, quick call rating, history, calendar.
class ContactDetailPane extends ConsumerStatefulWidget {
  final String contactId;
  final bool embedded;
  final ValueChanged<Contact>? onSelectContact;

  const ContactDetailPane({
    super.key,
    required this.contactId,
    this.embedded = true,
    this.onSelectContact,
  });

  @override
  ConsumerState<ContactDetailPane> createState() => _ContactDetailPaneState();
}

class _ContactDetailPaneState extends ConsumerState<ContactDetailPane> {
  int _quickRating = 4;
  final _quickNotes = TextEditingController();
  bool _isLogging = false;

  @override
  void dispose() {
    _quickNotes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contactAsync = ref.watch(contactByIdProvider(widget.contactId));
    final callLogsAsync = ref.watch(callLogNotifierProvider);

    return contactAsync.when(
      data: (contact) {
        if (contact == null) {
          return const EmptyState(
            icon: Icons.person_off_outlined,
            title: 'Contact not found',
            message: 'This person may have been removed.',
          );
        }

        final logs = callLogsAsync.value
                ?.where((l) => l.contactId == widget.contactId)
                .toList() ??
            [];
        final statusType = ref.watch(contactStatusMapProvider)[contact.id];

        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PremiumCard(
                child: Column(
                  children: [
                    StatusAvatar(
                      initials: contact.initials,
                      statusType: statusType,
                      imageUrl: contact.photoUrl,
                      radius: 44,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      contact.name,
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      contact.phone,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.vibrantGreen,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    if (contact.email != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        contact.email!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      contact.daysSinceLastCall == null
                          ? 'Never called — great time to reach out'
                          : 'Last called ${contact.lastCalledAt!.toRelativeDateString()}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: contact.isOverdue
                                ? AppColors.brightOrange
                                : AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: PrimaryButton(
                            label: 'Call',
                            icon: Icons.phone_rounded,
                            fullWidth: true,
                            onPressed: () => _call(contact),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        IconButton.filledTonal(
                          tooltip: 'Edit',
                          onPressed: () =>
                              context.push('/contacts/${contact.id}/edit'),
                          icon: const Icon(Icons.edit_outlined),
                        ),
                        IconButton.filledTonal(
                          tooltip: 'Message',
                          onPressed: () => _message(contact),
                          icon: const Icon(Icons.sms_outlined),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              PremiumCard(
                accentColor: AppColors.brightOrange,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rate your call',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      'How did it feel? Quick log without leaving this screen.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Center(
                      child: StarRating(
                        rating: _quickRating,
                        size: 36,
                        onChanged: (v) => setState(() => _quickRating = v),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: _quickNotes,
                      decoration: const InputDecoration(
                        labelText: 'Notes (optional)',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    PrimaryButton(
                      label: 'Log call & rating',
                      icon: Icons.check_circle_outline,
                      fullWidth: true,
                      isLoading: _isLogging,
                      onPressed: () => _logQuickCall(contact),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              ContactsCalendarPanel(
                contact: contact,
                onContactSelected: widget.onSelectContact,
              ),
              if (logs.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Recent calls',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                ...logs.take(5).map((log) => _CallHistoryTile(log: log)),
              ],
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => ErrorState(
        error: e,
        title: Microcopy.errorLoadContacts,
        onRetry: () => ref.invalidate(contactByIdProvider(widget.contactId)),
      ),
    );
  }

  Future<void> _logQuickCall(Contact contact) async {
    final userId = ref.read(contactsNotifierProvider.notifier).currentUserId;
    if (userId == null) return;

    setState(() => _isLogging = true);
    try {
      await ref.read(callLogNotifierProvider.notifier).addLog(
            CallLog(
              userId: userId,
              contactId: widget.contactId,
              calledAt: DateTime.now(),
              callRating: _quickRating,
              notes: _quickNotes.text.trim().isEmpty
                  ? null
                  : _quickNotes.text.trim(),
            ),
          );
      _quickNotes.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(Microcopy.callSaved)),
        );
      }
    } catch (e) {
      if (mounted) {
        AppMessenger.showError(context, e);
      }
    } finally {
      if (mounted) setState(() => _isLogging = false);
    }
  }

  Future<void> _call(Contact contact) async {
    final uri = Uri(scheme: 'tel', path: contact.phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _message(Contact contact) async {
    final uri = Uri(scheme: 'sms', path: contact.phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }
}

class _CallHistoryTile extends StatelessWidget {
  final CallLog log;

  const _CallHistoryTile({required this.log});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat.yMMMd().add_jm();
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
      child: Material(
        color: AppColors.cardSurface(context),
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        child: ListTile(
          dense: true,
          leading: const CircleAvatar(
            backgroundColor: AppColors.softGreen,
            child: Icon(Icons.phone_in_talk,
                color: AppColors.vibrantGreen, size: 18),
          ),
          title: Text(fmt.format(log.calledAt)),
          subtitle: Text(log.notes ?? 'No notes', maxLines: 1),
          trailing: log.callRating != null
              ? StarRating(rating: log.callRating!, size: 16)
              : null,
        ),
      ),
    );
  }
}
