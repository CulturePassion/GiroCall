import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/design/colors.dart';
import '../../../core/design/spacing.dart';
import '../../../core/supabase_provider.dart';
import '../../../core/utils/card_url.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/utils/screen_padding.dart';
import '../../../shared/models/user_profile.dart';
import '../../../shared/widgets/gradient_background.dart';
import '../../../shared/widgets/live_clock_header.dart';
import '../../../shared/widgets/premium_card.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/profile_notifier.dart';
import '../services/contact_save_service.dart';
import '../services/wallet_service.dart';
import '../widgets/digital_card_view.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileNotifierProvider);

    return profileAsync.when(
      data: (profile) {
        if (profile == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return _ProfileLayout(profile: profile);
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        body: Center(child: Text('Error: $error')),
      ),
    );
  }
}

class _ProfileLayout extends ConsumerWidget {
  final UserProfile profile;

  const _ProfileLayout({required this.profile});

  static const double _cardMaxWidth = 440;
  static const double _sidePaneWidth = 460;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSplit = ResponsiveLayout.isDesktop(context);
    final hPad = ResponsiveLayout.horizontalPadding(context);
    final bottom = ScreenPadding.bottomNavClearance(context);
    final supabaseUrl = ref.watch(supabaseConfigProvider).url;
    final walletService = WalletService(supabaseUrl: supabaseUrl);
    final cardUrl = CardUrl.publicCardUrl(profile.slug);

    final cardPane = _LinkInBioPane(
      profile: profile,
      cardUrl: cardUrl,
      walletService: walletService,
    );
    final accountPane = _AccountPane(profile: profile);

    if (isSplit) {
      return GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(hPad, AppSpacing.xs, hPad, bottom),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: _sidePaneWidth,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const LiveClockHeader(lightText: true),
                        const SizedBox(height: AppSpacing.sm),
                        cardPane,
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: SingleChildScrollView(child: accountPane),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return GradientBackground(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: ScreenPadding.contactsPane(context).copyWith(bottom: bottom),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _cardMaxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const LiveClockHeader(lightText: true),
                  const SizedBox(height: AppSpacing.sm),
                  cardPane,
                  const SizedBox(height: AppSpacing.md),
                  accountPane,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LinkInBioPane extends ConsumerWidget {
  final UserProfile profile;
  final String cardUrl;
  final WalletService walletService;

  const _LinkInBioPane({
    required this.profile,
    required this.cardUrl,
    required this.walletService,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = AppColors.isDark(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!profile.isPublic)
          Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.accentCoral.withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.visibility_off_outlined,
                  color: Colors.white.withValues(alpha: 0.95),
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    'Your card is private. Turn on public sharing below to get '
                    'your girocall.com/me link, QR code, and share actions.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.95),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        DigitalCardView(
          profile: profile,
          variant: DigitalCardVariant.owner,
          showQr: profile.isPublic,
          onSaveContact: () =>
              ref.read(contactSaveServiceProvider).saveProfileContact(profile),
          onShare: profile.isPublic
              ? () => SharePlus.instance.share(
                    ShareParams(
                      text: 'Connect with ${profile.displayName}: $cardUrl',
                    ),
                  )
              : null,
          onEdit: () => context.push('/profile/edit'),
          onAppleWallet: profile.isPublic && walletService.isMobile
              ? () => walletService.addToAppleWallet(profile.slug)
              : null,
          onGoogleWallet: profile.isPublic && walletService.isMobile
              ? () => walletService.addToGoogleWallet(profile.slug)
              : null,
        ),
      ],
    );
  }
}

class _AccountPane extends ConsumerWidget {
  final UserProfile profile;

  const _AccountPane({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PremiumCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Account',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Public digital card'),
            subtitle: Text(
              profile.isPublic
                  ? 'Anyone with girocall.com/me/${profile.slug} can view your card.'
                  : 'Only you can see your card right now.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            value: profile.isPublic,
            onChanged: (value) async {
              await ref.read(profileNotifierProvider.notifier).saveProfile(
                    profile.copyWith(isPublic: value),
                  );
            },
            secondary: Icon(
              profile.isPublic ? Icons.public : Icons.lock_outline,
              color: profile.isPublic ? AppColors.success : AppColors.warmGray,
            ),
          ),
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings'),
          ),
          const SizedBox(height: AppSpacing.sm),
          PrimaryButton(
            label: 'Sign out',
            icon: Icons.logout_rounded,
            backgroundColor: AppColors.error,
            onPressed: () => ref.read(authNotifierProvider.notifier).signOut(),
          ),
        ],
      ),
    );
  }
}