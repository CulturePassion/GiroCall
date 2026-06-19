import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/colors.dart';
import '../../../core/design/microcopy.dart';
import '../../../core/design/spacing.dart';
import '../../../core/design/tokens.dart';
import '../../../shared/models/presence_status.dart';
import '../../../shared/models/user_profile.dart';
import '../../../shared/widgets/page_header.dart';
import '../../../shared/widgets/premium_card.dart';
import '../../../shared/widgets/primary_button.dart';
import 'presence_selector.dart';
import 'status_avatar.dart';

class StatusMyPresenceSection extends StatelessWidget {
  final UserProfile? profile;
  final PresenceType? selected;
  final ValueChanged<PresenceType> onSelected;
  final TextEditingController customMessageController;
  final bool saving;
  final bool missingPhone;
  final VoidCallback onSave;

  const StatusMyPresenceSection({
    super.key,
    required this.profile,
    required this.selected,
    required this.onSelected,
    required this.customMessageController,
    required this.saving,
    required this.missingPhone,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final currentType = PresenceType.fromValue(profile?.presenceType);
    final currentMessage = profile?.presenceMessage;
    final previewType = selected ?? currentType;
    final previewMessage = previewType?.displayMessage(
      selected == PresenceType.custom
          ? customMessageController.text
          : currentMessage,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const PageHeader(
          title: Microcopy.statusMyTitle,
          subtitle: Microcopy.statusMySubtitle,
        ),
        if (missingPhone) ...[
          _PhoneBanner(onTap: () => context.push('/profile/edit')),
          const SizedBox(height: AppSpacing.sm),
        ],
        PremiumCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  StatusAvatar(
                    initials: profile?.displayName.isNotEmpty == true
                        ? profile!.displayName[0].toUpperCase()
                        : '?',
                    statusType: previewType,
                    imageUrl: profile?.avatarUrl,
                    radius: 28,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile?.displayName ?? 'You',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          previewMessage ?? 'Choose how you\'re feeling',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: previewType != null
                                        ? previewType.color
                                        : AppColors.textMuted(context),
                                    fontWeight: previewType != null
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              PresenceSelector(
                selected: selected,
                onSelected: onSelected,
                customMessageController: customMessageController,
              ),
              const SizedBox(height: AppSpacing.md),
              PrimaryButton(
                label: saving ? 'Saving…' : 'Update my status',
                icon: Icons.bolt_rounded,
                isLoading: saving,
                onPressed: selected == null ? null : onSave,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PhoneBanner extends StatelessWidget {
  final VoidCallback onTap;

  const _PhoneBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.softOrange,
      borderRadius: BorderRadius.circular(AppTokens.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
            border: Border.all(color: AppColors.orange.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              const Icon(Icons.phone_outlined, color: AppColors.orange),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  'Add your phone in Edit Profile so friends can reach you.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppColors.textMuted(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
