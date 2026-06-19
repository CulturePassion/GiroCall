import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/colors.dart';
import '../../../core/design/spacing.dart';
import '../../../core/design/tokens.dart';
import '../../../core/supabase_provider.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/glass_surface.dart';
import '../../../shared/widgets/responsive_page.dart';
import '../../../shared/widgets/settings_section.dart';
import '../../auth/providers/auth_provider.dart';
import '../../profile/providers/profile_notifier.dart';

/// Account management — profile, password, sign out, delete.
class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authUserProvider).value?.session?.user;
    final profile = ref.watch(profileNotifierProvider).value;
    final email = user?.email ?? 'Not signed in';
    final createdAt = user?.createdAt;
    final displayName = profile?.displayName ??
        (email.contains('@') ? email.split('@').first : 'GiroCall user');

    return AppScaffold(
      title: 'Account',
      responsiveWidth: null,
      body: ResponsivePage(
        width: ResponsivePageWidth.form,
        scrollable: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GlassSurface(
              padding: const EdgeInsets.all(AppSpacing.sm),
              borderRadius: AppTokens.radiusLg,
              child: Row(
                children: [
                  _AccountAvatar(
                    imageUrl: profile?.avatarUrl,
                    name: displayName,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        if (createdAt != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Member since ${_formatDate(createdAt)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            SettingsSection(
              title: 'PROFILE',
              children: [
                SettingsTile(
                  icon: Icons.badge_outlined,
                  title: 'My /me page',
                  subtitle: 'Public link, username, and sharing',
                  onTap: () => context.go('/profile/card'),
                ),
                SettingsTile(
                  icon: Icons.edit_outlined,
                  title: 'Edit profile',
                  subtitle: 'Name, bio, contact info, and social links',
                  onTap: () => context.go('/profile/edit'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            SettingsSection(
              title: 'SECURITY',
              children: [
                SettingsTile(
                  icon: Icons.lock_reset,
                  title: 'Change password',
                  subtitle: 'Update your sign-in password',
                  onTap: () => context.push('/settings/account/password'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            SettingsSection(
              title: 'SESSION',
              children: [
                SettingsTile(
                  icon: Icons.logout,
                  title: 'Sign out',
                  subtitle: 'Sign back in anytime on any device',
                  onTap: () => _confirmSignOut(context, ref),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            SettingsSection(
              title: 'DATA & PRIVACY',
              children: [
                SettingsTile(
                  icon: Icons.delete_forever_outlined,
                  iconColor: AppColors.error,
                  titleColor: AppColors.error,
                  title: 'Delete account and data',
                  subtitle: 'Permanently removes contacts, logs, and settings',
                  onTap: () => _confirmDeleteAccount(context, ref),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Your contacts and call history are private to your account. '
              'We never share phone numbers in push notifications.',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      final date = DateTime.parse(iso);
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[date.month - 1]} ${date.year}';
    } catch (_) {
      return iso;
    }
  }

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text(
          'You can sign back in anytime. Your data stays synced in the cloud.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(authNotifierProvider.notifier).signOut();
    }
  }

  Future<void> _confirmDeleteAccount(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete account?'),
        content: const Text(
          'This permanently deletes your account, contacts, call logs, '
          'and settings. This cannot be undone.',
        ),
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
      await ref.read(authNotifierProvider.notifier).deleteAccount();
    }
  }
}

class _AccountAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name;

  const _AccountAvatar({this.imageUrl, required this.name});

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        child: Image.network(
          imageUrl!,
          width: 64,
          height: 64,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallback(initial),
        ),
      );
    }
    return _fallback(initial);
  }

  Widget _fallback(String initial) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.vibrantGreen, AppColors.softBluePurple],
        ),
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
