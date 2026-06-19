import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/design/spacing.dart';
import '../../../core/supabase_provider.dart';
import '../../../core/utils/card_url.dart';
import '../../../core/design/microcopy.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/gradient_background.dart';
import '../providers/profile_notifier.dart';
import '../services/contact_save_service.dart';
import '../services/wallet_service.dart';
import '../widgets/digital_card_view.dart';

/// Public link-in-bio page — no auth required.
class PublicCardScreen extends ConsumerWidget {
  final String slug;

  const PublicCardScreen({super.key, required this.slug});

  static const double _maxWidth = 440;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(publicProfileProvider(slug));
    final supabaseUrl = ref.watch(supabaseConfigProvider).url;
    final walletService = WalletService(supabaseUrl: supabaseUrl);

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: profileAsync.when(
            data: (profile) {
              if (profile == null) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: EmptyState(
                      icon: Icons.search_off_outlined,
                      title: 'Card not found',
                      message:
                          'This digital card may be private or the link may be incorrect.',
                    ),
                  ),
                );
              }

              final cardUrl = CardUrl.publicCardUrl(profile.slug);

              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: _maxWidth),
                    child: DigitalCardView(
                      profile: profile,
                      variant: DigitalCardVariant.public,
                      onSaveContact: () => ref
                          .read(contactSaveServiceProvider)
                          .saveProfileContact(profile),
                      onShare: () => SharePlus.instance.share(
                        ShareParams(
                          text: 'Connect with ${profile.displayName}: $cardUrl',
                        ),
                      ),
                      onAppleWallet: walletService.isMobile
                          ? () => walletService.addToAppleWallet(profile.slug)
                          : null,
                      onGoogleWallet: walletService.isMobile
                          ? () => walletService.addToGoogleWallet(profile.slug)
                          : null,
                    ),
                  ),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => ErrorState(
              error: error,
              title: Microcopy.errorLoadProfile,
              onRetry: () => ref.invalidate(publicProfileProvider(slug)),
            ),
          ),
        ),
      ),
    );
  }
}
