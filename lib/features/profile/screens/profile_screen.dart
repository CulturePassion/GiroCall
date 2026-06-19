import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/colors.dart';
import '../../../core/design/microcopy.dart';
import '../../../core/design/spacing.dart';
import '../../../core/design/tokens.dart';
import '../../../core/utils/screen_padding.dart';
import '../../../shared/models/user_profile.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/glass_surface.dart';
import '../../../shared/widgets/live_clock_header.dart';
import '../../../shared/widgets/settings_section.dart';
import '../../../shared/widgets/shell_content.dart';
import '../providers/profile_notifier.dart';

/// Hub for profile, digital card, account, and settings — separate from /me/:slug.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileNotifierProvider);

    return profileAsync.when(
      data: (profile) {
        if (profile == null) {
          return const AppScaffold(
            variant: AppScaffoldVariant.hero,
            title: 'You',
            showBackButton: false,
            body: Center(child: CircularProgressIndicator(color: Colors.white)),
          );
        }
        return AppScaffold(
          variant: AppScaffoldVariant.hero,
          title: 'You',
          showBackButton: false,
          body: _ProfileHub(profile: profile),
        );
      },
      loading: () => const AppScaffold(
        variant: AppScaffoldVariant.hero,
        title: 'You',
        showBackButton: false,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      ),
      error: (error, _) => AppScaffold(
        variant: AppScaffoldVariant.hero,
        title: 'You',
        showBackButton: false,
        body: ErrorState(
          error: error,
          title: Microcopy.errorLoadProfile,
          onRetry: () =>
              ref.read(profileNotifierProvider.notifier).loadProfile(),
        ),
      ),
    );
  }
}

class _ProfileHub extends StatelessWidget {
  final UserProfile profile;

  const _ProfileHub({required this.profile});

  @override
  Widget build(BuildContext context) {
    final bottom = ScreenPadding.bottomNavClearance(context);

    return ShellContent(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          bottom + AppSpacing.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const LiveClockHeader(lightText: true),
            const SizedBox(height: AppSpacing.md),
            _ProfileHeader(profile: profile),
            const SizedBox(height: AppSpacing.lg),
            // Digital Card section with refined modern spacing
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration:
                  AppTokens.animationNormal + const Duration(milliseconds: 120),
              curve: Curves.easeOut,
              builder: (context, value, child) =>
                  Opacity(opacity: value, child: child),
              child: SettingsSection(
                title: 'DIGITAL CARD',
                children: [
                  SettingsTile(
                    icon: Icons.badge_outlined,
                    title: 'My /me page',
                    subtitle: profile.isPublic
                        ? 'girocall.com/me/${profile.slug}'
                        : 'Private — turn on sharing to get your link',
                    onTap: () => context.push('/profile/card'),
                  ),
                  SettingsTile(
                    icon: Icons.edit_outlined,
                    title: 'Edit card details',
                    subtitle: 'Name, bio, contact info, and social links',
                    onTap: () => context.push('/profile/edit'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration:
                  AppTokens.animationNormal + const Duration(milliseconds: 240),
              curve: Curves.easeOut,
              builder: (context, value, child) =>
                  Opacity(opacity: value, child: child),
              child: SettingsSection(
                title: 'ACCOUNT & APP',
                children: [
                  SettingsTile(
                    icon: Icons.account_circle_outlined,
                    title: 'Account',
                    subtitle: 'Email, password, sign out, delete account',
                    onTap: () => context.push('/settings/account'),
                  ),
                  SettingsTile(
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    subtitle: 'Theme, notifications, and about',
                    onTap: () => context.push('/settings'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final UserProfile profile;

  const _ProfileHeader({required this.profile});

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      if (profile.title != null && profile.title!.isNotEmpty) profile.title!,
      if (profile.company != null && profile.company!.isNotEmpty)
        profile.company!,
    ].join(' · ');

    // Subtle entrance animation for modern feel
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: AppTokens.animationNormal,
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 12),
            child: child,
          ),
        );
      },
      child: GlassSurface(
        frosted: true,
        blurSigma: 14,
        padding: const EdgeInsets.all(AppSpacing.md),
        borderRadius: AppTokens.radiusLg,
        child: Row(
          children: [
            // Animated avatar scale on entry + subtle brand glow
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.8, end: 1.0),
              duration: AppTokens.animationSlow,
              curve: Curves.elasticOut,
              builder: (context, scale, child) => Transform.scale(
                scale: scale,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.vibrantGreen.withValues(alpha: 0.35),
                        blurRadius: 18,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 32,
                    backgroundImage: profile.avatarUrl != null
                        ? NetworkImage(profile.avatarUrl!)
                        : null,
                    backgroundColor: AppColors.vibrantGreen,
                    child: profile.avatarUrl == null
                        ? Text(
                            profile.displayName.isNotEmpty
                                ? profile.displayName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 22,
                            ),
                          )
                        : null,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.displayName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
