import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/design/colors.dart';
import '../../../core/design/spacing.dart';
import '../../../core/design/tokens.dart';
import '../../../core/utils/screen_padding.dart';
import '../../../shared/models/contact.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../call_log/providers/call_log_notifier.dart';
import '../providers/contact_by_id_provider.dart';

class ContactDetailScreen extends ConsumerWidget {
  final String contactId;

  const ContactDetailScreen({super.key, required this.contactId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactAsync = ref.watch(contactByIdProvider(contactId));
    final callLogsAsync = ref.watch(callLogNotifierProvider);

    return contactAsync.when(
      data: (contact) {
        if (contact == null) {
          return const AppScaffold(
            title: 'Contact',
            body: Center(child: Text('Contact not found')),
          );
        }

        final logs = callLogsAsync.value
                ?.where((log) => log.contactId == contactId)
                .toList() ??
            [];

        return AppScaffold(
          title: contact.name,
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => context.push('/contacts/$contactId/edit'),
            ),
          ],
          body: SingleChildScrollView(
            padding: ScreenPadding.all(context),
            child: Column(
              children: [
                // Contact avatar and basic info
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppTokens.radiusXl),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildAvatar(contact),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        contact.name,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      if (contact.firstName != null || contact.lastName != null)
                        Text(
                          '${contact.firstName ?? ''} ${contact.lastName ?? ''}'
                              .trim(),
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                        ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.phone,
                            color: AppColors.primaryTeal,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            contact.phone,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      if (contact.email != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.email,
                              color: AppColors.primaryTeal,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              contact.email!,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // Action buttons
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    _buildActionChip(
                      context: context,
                      icon: Icons.phone,
                      label: 'Call',
                      color: AppColors.primaryTeal,
                      onPressed: () => _callContact(contact),
                    ),
                    _buildActionChip(
                      context: context,
                      icon: Icons.sms,
                      label: 'Message',
                      color: AppColors.goldenYellow,
                      onPressed: () => _messageContact(contact),
                    ),
                    _buildActionChip(
                      context: context,
                      icon: Icons.history,
                      label: 'Log Call',
                      color: AppColors.accentCoral,
                      onPressed: () => context.push('/call/$contactId'),
                    ),
                    if (contact.website != null)
                      _buildActionChip(
                        context: context,
                        icon: Icons.public,
                        label: 'Visit Site',
                        color: AppColors.premiumPurple,
                        onPressed: () => _openWebsite(contact.website!),
                      ),
                  ],
                ),

                const SizedBox(height: AppSpacing.md),

                // Contact details section
                if (contact.notes != null ||
                    contact.company != null ||
                    contact.jobTitle != null ||
                    contact.formattedAddress != null)
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppTokens.radiusLg),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (contact.notes != null) ...[
                          Text(
                            'Notes',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            contact.notes!,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const Divider(height: AppSpacing.md),
                        ],
                        if (contact.company != null ||
                            contact.jobTitle != null) ...[
                          Text(
                            'Work',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          if (contact.jobTitle != null)
                            Text(
                              contact.jobTitle!,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          if (contact.company != null)
                            Text(
                              contact.company!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                            ),
                          if (contact.company != null ||
                              contact.jobTitle != null)
                            const Divider(height: AppSpacing.md),
                        ],
                        if (contact.formattedAddress != null) ...[
                          Text(
                            'Address',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            contact.formattedAddress!,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ],
                    ),
                  ),

                const SizedBox(height: AppSpacing.md),

                // Call history
                if (logs.isNotEmpty) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Call History',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ...logs.take(5).map((log) => Card(
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppColors.softBlue,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.phone_missed,
                              color: AppColors.primaryTeal,
                            ),
                          ),
                          title: Text(
                            'Called on ${log.calledAt.day}/${log.calledAt.month}/${log.calledAt.year}',
                          ),
                          subtitle: Text(
                            log.notes ?? 'No notes',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: log.callRating != null
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: List.generate(
                                    5,
                                    (index) => Icon(
                                      index < log.callRating!
                                          ? Icons.star
                                          : Icons.star_border,
                                      color: index < log.callRating!
                                          ? Colors.orange
                                          : null,
                                      size: 16,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                      )),
                ],
              ],
            ),
          ),
        );
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

  Widget _buildAvatar(Contact contact) {
    final initials = contact.initials;
    return CircleAvatar(
      radius: 50,
      backgroundColor: AppColors.primaryTeal,
      child: Text(
        initials,
        style: const TextStyle(
          fontSize: 32,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildActionChip({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
      selected: false,
      onSelected: (_) => onPressed(),
      selectedColor: color,
      backgroundColor: color.withValues(alpha: 0.2),
      showCheckmark: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        side: BorderSide.none,
      ),
    );
  }

  Future<void> _callContact(Contact contact) async {
    final uri = Uri(scheme: 'tel', path: contact.phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _messageContact(Contact contact) async {
    final uri = Uri(scheme: 'sms', path: contact.phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openWebsite(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
