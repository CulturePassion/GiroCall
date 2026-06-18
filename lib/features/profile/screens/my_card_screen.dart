import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/design/colors.dart';
import '../../../core/design/spacing.dart';
import '../../../core/supabase_provider.dart';
import '../../../core/utils/card_url.dart';
import '../../../core/utils/screen_padding.dart';
import '../../../core/utils/supabase_error_message.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/gradient_background.dart';
import '../../../shared/widgets/primary_button.dart';
import '../providers/profile_notifier.dart';
import '../services/contact_save_service.dart';
import '../services/wallet_service.dart';
import '../widgets/digital_card_view.dart';

class MyCardScreen extends ConsumerWidget {
  const MyCardScreen({super.key});

  static const double _maxWidth = 440;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileNotifierProvider);
    final supabaseUrl = ref.watch(supabaseConfigProvider).url;
    final walletService = WalletService(supabaseUrl: supabaseUrl);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Digital Card'),
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

          final cardUrl = CardUrl.publicCardUrl(profile.slug);

          return GradientBackground(
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: ScreenPadding.all(context),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: _maxWidth),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
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
                          onAppleWallet:
                              profile.isPublic && walletService.isMobile
                                  ? () => walletService
                                      .addToAppleWallet(profile.slug)
                                  : null,
                          onGoogleWallet:
                              profile.isPublic && walletService.isMobile
                                  ? () => walletService
                                      .addToGoogleWallet(profile.slug)
                                  : null,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        PrimaryButton(
                          label: 'Back to profile',
                          icon: Icons.arrow_back_rounded,
                          onPressed: () => context.pop(),
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
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(supabaseErrorMessage(error)),
          ),
        ),
      ),
    );
  }
}