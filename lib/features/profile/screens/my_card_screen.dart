import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/design/colors.dart';
import '../../../core/design/spacing.dart';
import '../../../core/design/tokens.dart';
import '../../../core/supabase_provider.dart';
import '../../../core/utils/card_url.dart';
import '../../../core/utils/screen_padding.dart';
import '../../../core/design/microcopy.dart';
import '../../../core/errors/app_messenger.dart';
import '../../../shared/models/user_profile.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/gradient_background.dart';
import '../../../shared/widgets/premium_card.dart';
import '../../../shared/widgets/primary_button.dart';
import '../providers/profile_notifier.dart';
import '../providers/profile_repository_provider.dart';
import '../services/contact_save_service.dart';
import '../services/wallet_service.dart';
import '../widgets/digital_card_view.dart';

/// Owner view for your public /me/:username page — separate from profile hub.
class MyCardScreen extends ConsumerStatefulWidget {
  const MyCardScreen({super.key});

  @override
  ConsumerState<MyCardScreen> createState() => _MyCardScreenState();
}

class _MyCardScreenState extends ConsumerState<MyCardScreen> {
  final _slugController = TextEditingController();
  bool _slugInitialized = false;
  bool _savingSlug = false;

  @override
  void dispose() {
    _slugController.dispose();
    super.dispose();
  }

  void _initSlug(UserProfile profile) {
    if (_slugInitialized) return;
    _slugController.text = profile.slug;
    _slugInitialized = true;
  }

  Future<void> _saveSlug(UserProfile profile) async {
    final slug = _slugController.text.trim().toLowerCase();
    if (slug == profile.slug) return;

    setState(() => _savingSlug = true);
    try {
      final repo = ref.read(profileRepositoryProvider);
      final available = await repo.isSlugAvailable(
        slug,
        excludeUserId: profile.userId,
      );
      if (!available) {
        if (mounted) {
          AppMessenger.showInfo(context, 'That username is already taken.');
        }
        return;
      }

      await ref.read(profileNotifierProvider.notifier).saveProfile(
            profile.copyWith(slug: slug),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Username updated.')),
        );
      }
    } catch (e) {
      if (mounted) AppMessenger.showError(context, e);
    } finally {
      if (mounted) setState(() => _savingSlug = false);
    }
  }

  Future<void> _openPublicPage(String slug) async {
    final uri = Uri.parse(CardUrl.publicCardUrl(slug));
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileNotifierProvider);
    final supabaseUrl = ref.watch(supabaseConfigProvider).url;
    final walletService = WalletService(supabaseUrl: supabaseUrl);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My /me Page'),
        backgroundColor: AppColors.main,
        foregroundColor: Colors.white,
      ),
      body: profileAsync.when(
        data: (profile) {
          if (profile == null) {
            return const EmptyState(
              icon: Icons.badge_outlined,
              title: 'Sign in to create your card',
              message:
                  'Your digital business card helps you network and stay connected.',
            );
          }

          _initSlug(profile);
          final cardUrl = CardUrl.publicCardUrl(profile.slug);

          return GradientBackground(
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: ScreenPadding.all(context),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        PremiumCard(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
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
                                  await ref
                                      .read(profileNotifierProvider.notifier)
                                      .saveProfile(
                                        profile.copyWith(isPublic: value),
                                      );
                                },
                                secondary: Icon(
                                  profile.isPublic
                                      ? Icons.public
                                      : Icons.lock_outline,
                                  color: profile.isPublic
                                      ? AppColors.success
                                      : AppColors.warmGray,
                                ),
                              ),
                              const Divider(),
                              TextField(
                                controller: _slugController,
                                enabled: !_savingSlug,
                                decoration: const InputDecoration(
                                  labelText: 'Username',
                                  prefixIcon: Icon(Icons.link),
                                  hintText: 'your-name',
                                  helperText:
                                      'Lowercase letters, numbers, and hyphens',
                                ),
                                onSubmitted: (_) => _saveSlug(profile),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  onPressed: _savingSlug
                                      ? null
                                      : () => _saveSlug(profile),
                                  icon: _savingSlug
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(Icons.check, size: 18),
                                  label: const Text('Save username'),
                                ),
                              ),
                              if (profile.isPublic) ...[
                                const Divider(),
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: const Icon(Icons.open_in_new),
                                  title: const Text('View public page'),
                                  subtitle: Text(cardUrl),
                                  onTap: () => _openPublicPage(profile.slug),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        if (!profile.isPublic)
                          Container(
                            margin:
                                const EdgeInsets.only(bottom: AppSpacing.sm),
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.18),
                              borderRadius:
                                  BorderRadius.circular(AppTokens.radiusMd),
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
                                    'Turn on public sharing above to get your '
                                    'girocall.com/me link, QR code, and share actions.',
                                    style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.95),
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
                          onSaveContact: () => ref
                              .read(contactSaveServiceProvider)
                              .saveProfileContact(profile),
                          onShare: profile.isPublic
                              ? () => SharePlus.instance.share(
                                    ShareParams(
                                      text:
                                          'Connect with ${profile.displayName}: $cardUrl',
                                    ),
                                  )
                              : null,
                          onEdit: () => context.push('/profile/edit'),
                          onAppleWallet: profile.isPublic &&
                                  walletService.isMobile
                              ? () =>
                                  walletService.addToAppleWallet(profile.slug)
                              : null,
                          onGoogleWallet: profile.isPublic &&
                                  walletService.isMobile
                              ? () =>
                                  walletService.addToGoogleWallet(profile.slug)
                              : null,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        PrimaryButton(
                          label: 'Back to You',
                          icon: Icons.arrow_back_rounded,
                          onPressed: () => context.go('/profile'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorState(
          error: error,
          title: Microcopy.errorLoadProfile,
          onRetry: () =>
              ref.read(profileNotifierProvider.notifier).loadProfile(),
        ),
      ),
    );
  }
}
