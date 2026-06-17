import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/app_colors.dart';
import '../../../core/app_spacing.dart';
import '../../../core/constants.dart';
import '../../../core/supabase_provider.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/utils/screen_padding.dart';
import '../../../core/utils/supabase_error_message.dart';
import '../../../shared/widgets/glass_surface.dart';
import '../../../shared/widgets/gradient_background.dart';
import '../../../shared/widgets/responsive_page.dart';
import '../../stats/providers/stats_provider.dart';
import '../providers/profile_notifier.dart';

/// Profile hub — glass cards, colorful stats, thumb-friendly navigation.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authUserProvider).value?.session?.user;
    final profileAsync = ref.watch(profileNotifierProvider);
    final stats = ref.watch(statsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: profileAsync.when(
            data: (profile) {
              final displayName = profile?.displayName ??
                  user?.email?.split('@').first ??
                  'GiroCall user';
              final email = user?.email ?? '';

              return ResponsivePage(
                width: ResponsivePageWidth.content,
                scrollable: false,
                padding: EdgeInsets.zero,
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          ResponsiveLayout.horizontalPadding(context),
                          AppSpacing.xs,
                          ResponsiveLayout.horizontalPadding(context),
                          AppSpacing.xxs,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Profile',
                              style: theme.textTheme.displaySmall,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            _ProfileHeader(
                              displayName: displayName,
                              email: email,
                              subtitle: profile?.title,
                              avatarUrl: profile?.avatarUrl,
                              onEdit: () => context.push('/profile/edit'),
                            ),
                          const SizedBox(height: AppSpacing.sm),
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
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveLayout.horizontalPadding(context),
                      ),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          GlassSurface(
                            padding: EdgeInsets.zero,
                            borderRadius: AppSpacing.radiusLg,
                            child: Column(
                              children: _withDividers(context, [
                                _ProfileMenuTile(
                                  icon: Icons.edit_outlined,
                                  iconColor: AppColors.main,
                                  title: 'Edit profile & photo',
                                  subtitle: 'Avatar, name, and contact details',
                                  onTap: () => context.push('/profile/edit'),
                                ),
                                _ProfileMenuTile(
                                  icon: Icons.badge_outlined,
                                  iconColor: AppColors.blue,
                                  title: 'My Digital Card',
                                subtitle: profile?.isPublic == true
                                    ? 'Public · ${profile!.slug}'
                                    : 'Private — tap to share when ready',
                                onTap: () => context.push('/profile/card'),
                              ),
                              _ProfileMenuTile(
                                icon: Icons.notifications_outlined,
                                iconColor: AppColors.paletteGold,
                                title: 'Reminders',
                                subtitle: 'Daily spin nudges and call goals',
                                onTap: () =>
                                    context.push('/settings/notifications'),
                              ),
                              _ProfileMenuTile(
                                icon: Icons.settings_outlined,
                                iconColor: AppColors.paletteSage,
                                title: 'Settings',
                                subtitle: 'Appearance, preferences, and more',
                                onTap: () => context.push('/settings'),
                              ),
                              _ProfileMenuTile(
                                icon: Icons.manage_accounts_outlined,
                                iconColor: AppColors.paletteCoral,
                                title: 'Account',
                                subtitle: 'Email, sign out, and data',
                                onTap: () => context.push('/settings/account'),
                              ),
                            ]),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
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
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Text(supabaseErrorMessage(error)),
              ),
            ),
          ),
        ),
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
          color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
        ));
      }
    }
    return result;
  }
}

class _ProfileHeader extends StatelessWidget {
  final String displayName;
  final String email;
  final String? subtitle;
  final String? avatarUrl;
  final VoidCallback onEdit;

  const _ProfileHeader({
    required this.displayName,
    required this.email,
    this.subtitle,
    this.avatarUrl,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassSurface(
      padding: const EdgeInsets.all(AppSpacing.xs),
      borderRadius: AppSpacing.radiusLg,
      child: Row(
        children: [
          _HeaderAvatar(
            imageUrl: avatarUrl,
            name: displayName,
          ),
          const SizedBox(width: AppSpacing.xs),
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
          IconButton(
            onPressed: onEdit,
            tooltip: 'Edit profile',
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
    );
  }
}

class _HeaderAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name;

  const _HeaderAvatar({this.imageUrl, required this.name});

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Image.network(
          imageUrl!,
          width: 72,
          height: 72,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _gradientBox(initial),
        ),
      );
    }
    return _gradientBox(initial);
  }

  Widget _gradientBox(String initial) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.main, AppColors.royalBlue, AppColors.sunsetOrange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
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
            color: AppColors.paletteCoral,
          ),
        ),
        const SizedBox(width: AppSpacing.xxs + 2),
        Expanded(
          child: _MiniStat(
            icon: Icons.phone_in_talk_outlined,
            value: '$totalCalls',
            label: 'Calls',
            color: AppColors.paletteTeal,
          ),
        ),
        const SizedBox(width: AppSpacing.xxs + 2),
        Expanded(
          child: _MiniStat(
            icon: Icons.people_outline,
            value: '$reconnected',
            label: 'People',
            color: AppColors.paletteGold,
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
    return GlassSurface(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.xs + 2,
        horizontal: AppSpacing.xxs + 4,
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: AppSpacing.xxs - 2),
          Text(
            value,
            style:
                Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20),
          ),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileMenuTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs - 2,
      ),
      leading: Container(
        width: AppSpacing.minTouchTarget,
        height: AppSpacing.minTouchTarget,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, height: 1.5),
      ),
      subtitle: Text(subtitle, style: const TextStyle(height: 1.5)),
      trailing: const Icon(Icons.chevron_right, size: 22),
      minVerticalPadding: 0,
    );
  }
}
