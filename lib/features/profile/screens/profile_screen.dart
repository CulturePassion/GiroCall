import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/app_colors.dart';
import '../../../core/constants.dart';
import '../../../core/supabase_provider.dart';
import '../../../core/utils/screen_padding.dart';
import '../../../core/utils/supabase_error_message.dart';
import '../../stats/providers/stats_provider.dart';
import '../providers/profile_notifier.dart';

/// Profile hub — account overview and navigation to card, settings, and account.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authUserProvider).value?.session?.user;
    final profileAsync = ref.watch(profileNotifierProvider);
    final stats = ref.watch(statsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: profileAsync.when(
          data: (profile) {
            final displayName = profile?.displayName ??
                user?.email?.split('@').first ??
                'GiroCall user';
            final email = user?.email ?? '';

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: ScreenPadding.all(context).copyWith(
                      top: 16,
                      bottom: 8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Profile',
                          style: theme.textTheme.displaySmall,
                        ),
                        const SizedBox(height: 20),
                        _ProfileHeader(
                          displayName: displayName,
                          email: email,
                          subtitle: profile?.title,
                        ),
                        const SizedBox(height: 20),
                        _QuickStatsRow(
                          streak: stats.currentStreak,
                          totalCalls: stats.totalCalls,
                          reconnected: stats.uniqueContactsCalled,
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: ScreenPadding.horizontal(context),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: 8),
                      _MenuCard(
                        children: [
                          _ProfileMenuTile(
                            icon: Icons.badge_outlined,
                            title: 'My Digital Card',
                            subtitle: profile?.isPublic == true
                                ? 'Public · ${profile!.slug}'
                                : 'Private — tap to share when ready',
                            onTap: () => context.push('/profile/card'),
                          ),
                          _ProfileMenuTile(
                            icon: Icons.notifications_outlined,
                            title: 'Reminders',
                            subtitle: 'Daily spin nudges and call goals',
                            onTap: () =>
                                context.push('/settings/notifications'),
                          ),
                          _ProfileMenuTile(
                            icon: Icons.settings_outlined,
                            title: 'Settings',
                            subtitle: 'Appearance, preferences, and more',
                            onTap: () => context.push('/settings'),
                          ),
                          _ProfileMenuTile(
                            icon: Icons.manage_accounts_outlined,
                            title: 'Account',
                            subtitle: 'Email, sign out, and data',
                            onTap: () => context.push('/settings/account'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        Constants.tagline,
                        style: theme.textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: ScreenPadding.bottomNavClearance(context),
                      ),
                    ]),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(supabaseErrorMessage(error)),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String displayName;
  final String email;
  final String? subtitle;

  const _ProfileHeader({
    required this.displayName,
    required this.email,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primaryTeal, AppColors.secondaryBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryTeal.withValues(alpha: 0.25),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: Text(
              displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(displayName, style: theme.textTheme.titleLarge),
              if (subtitle != null && subtitle!.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(subtitle!, style: theme.textTheme.bodyMedium),
              ],
              if (email.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(email, style: theme.textTheme.bodySmall),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickStatsRow extends StatelessWidget {
  final int streak;
  final int totalCalls;
  final int reconnected;

  const _QuickStatsRow({
    required this.streak,
    required this.totalCalls,
    required this.reconnected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MiniStat(
            icon: Icons.local_fire_department,
            value: '$streak',
            label: 'Streak',
            color: AppColors.accentCoral,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MiniStat(
            icon: Icons.phone_in_talk_outlined,
            value: '$totalCalls',
            label: 'Calls',
            color: AppColors.primaryTeal,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MiniStat(
            icon: Icons.people_outline,
            value: '$reconnected',
            label: 'People',
            color: AppColors.secondaryBlue,
          ),
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _MiniStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 20,
                  ),
            ),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final List<Widget> children;

  const _MenuCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: _withDividers(context, children),
      ),
    );
  }

  List<Widget> _withDividers(BuildContext context, List<Widget> items) {
    final result = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      result.add(items[i]);
      if (i < items.length - 1) {
        result.add(Divider(
          height: 1,
          indent: 72,
          color: Theme.of(context).dividerColor,
        ));
      }
    }
    return result;
  }
}

class _ProfileMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileMenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.primaryTeal.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.primaryTeal, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right, size: 22),
    );
  }
}
