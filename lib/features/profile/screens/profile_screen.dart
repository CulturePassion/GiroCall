import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/design/colors.dart';
import '../../../core/design/microcopy.dart';
import '../../../core/design/spacing.dart';
import '../../../core/design/tokens.dart';
import '../../../core/utils/screen_padding.dart';
import '../../../shared/models/user_profile.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/premium_card.dart';
import '../../../shared/widgets/profile_avatar_picker.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/profile_notifier.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileNotifierProvider);

    return AppScaffold(
      title: 'My Profile',
      actions: [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => context.push('/profile/edit'),
        ),
      ],
      body: profileAsync.when(
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text('Loading profile...'));
          }
          return _ProfileContent(profile: profile);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

class _ProfileContent extends ConsumerWidget {
  final UserProfile profile;

  const _ProfileContent({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: ScreenPadding.all(context).copyWith(
        bottom: ScreenPadding.bottomNavClearance(context),
      ),
      child: Column(
        children: [
          PremiumCard(
            accentColor: AppColors.main,
            borderRadius: AppTokens.radiusXl,
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                ProfileAvatarPicker(
                  imageUrl: profile.avatarUrl,
                  initials: profile.displayName.isNotEmpty
                      ? profile.displayName[0].toUpperCase()
                      : '?',
                  readonly: true,
                  radius: 60,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  profile.displayName,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                if (profile.title != null || profile.company != null)
                  Text(
                    [
                      if (profile.title != null) profile.title!,
                      if (profile.company != null) profile.company!,
                    ].join(' • '),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textMuted(context),
                        ),
                  ),
                if (profile.bio != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    profile.bio!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (profile.hasContactInfo)
            PremiumCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Microcopy.profileContactInfo,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (profile.phone != null)
                    _InfoRow(
                      icon: Icons.phone,
                      label: 'Phone',
                      value: profile.phone!,
                    ),
                  if (profile.email != null)
                    _InfoRow(
                      icon: Icons.email,
                      label: 'Email',
                      value: profile.email!,
                    ),
                  if (profile.formattedAddress != null)
                    _InfoRow(
                      icon: Icons.location_on,
                      label: 'Address',
                      value: profile.formattedAddress!,
                    ),
                ],
              ),
            ),
          if (profile.hasContactInfo) const SizedBox(height: AppSpacing.md),
          if (profile.socialLinks.isNotEmpty)
            PremiumCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Microcopy.profileSocialLinks,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: profile.socialLinks
                        .map(
                          (link) => _SocialLinkChip(
                            platform: link.platform,
                            label: link.label,
                            url: link.url,
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          if (profile.socialLinks.isNotEmpty)
            const SizedBox(height: AppSpacing.md),
          PremiumCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Microcopy.profilePrivacy,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Public profile'),
                  value: profile.isPublic,
                  onChanged: (_) {
                    // TODO: Implement profile privacy toggle
                  },
                  secondary: Icon(
                    Icons.visibility,
                    color: profile.isPublic
                        ? AppColors.success
                        : AppColors.error,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Card(
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.softBlue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.card_membership,
                  color: AppColors.primaryTeal,
                ),
              ),
              title: const Text('My Digital Card'),
              subtitle: const Text('Share your contact info easily'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/profile/card'),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          OutlinedButton.icon(
            onPressed: () => ref.read(authNotifierProvider.notifier).signOut(),
            icon: const Icon(Icons.logout),
            label: const Text('Sign out'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              side: const BorderSide(color: AppColors.error),
              foregroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTokens.radiusLg),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryTeal),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted(context),
                      ),
                ),
                Text(value, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialLinkChip extends StatelessWidget {
  final String platform;
  final String label;
  final String url;

  const _SocialLinkChip({
    required this.platform,
    required this.label,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _platformStyle(platform);

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
      selected: false,
      onSelected: (_) => _launchUrl(url),
      selectedColor: color,
      backgroundColor: color.withValues(alpha: 0.85),
      showCheckmark: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        side: BorderSide.none,
      ),
    );
  }

  (IconData, Color) _platformStyle(String platform) {
    switch (platform.toLowerCase()) {
      case 'linkedin':
        return (Icons.work, AppColors.royalBlue);
      case 'twitter':
      case 'x':
        return (Icons.tag, AppColors.warmBlue);
      case 'instagram':
        return (Icons.camera_alt, AppColors.softPink);
      case 'facebook':
        return (Icons.groups, AppColors.warmBlue);
      case 'tiktok':
        return (Icons.movie, AppColors.persianBlue);
      case 'youtube':
        return (Icons.play_circle, AppColors.error);
      case 'website':
        return (Icons.public, AppColors.primaryTeal);
      default:
        return (Icons.link, AppColors.warmGray);
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}