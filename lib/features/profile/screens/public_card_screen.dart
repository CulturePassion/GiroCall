import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants.dart';
import '../../../core/supabase_provider.dart';
import '../../../core/utils/card_url.dart';
import '../../../core/utils/supabase_error_message.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/empty_state.dart';
import '../providers/profile_notifier.dart';
import '../services/contact_save_service.dart';
import '../services/wallet_service.dart';
import '../widgets/digital_card_view.dart';

/// Public link-in-bio page — no auth required.
class PublicCardScreen extends ConsumerWidget {
  final String slug;

  const PublicCardScreen({super.key, required this.slug});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(publicProfileProvider(slug));
    final supabaseUrl = ref.watch(supabaseConfigProvider).url;
    final walletService = WalletService(supabaseUrl: supabaseUrl);

    return AppScaffold(
      title: Constants.appName,
      showBackButton: false,
      body: profileAsync.when(
        data: (profile) {
          if (profile == null) {
            return const EmptyState(
              icon: Icons.search_off_outlined,
              title: 'Card not found',
              message:
                  'This digital card may be private or the link may be incorrect.',
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: DigitalCardView(
              profile: profile,
              onSaveContact: () =>
                  const ContactSaveService().saveProfileContact(profile),
              onShare: () => SharePlus.instance.share(
                ShareParams(
                  text:
                      'Connect with ${profile.displayName}: ${CardUrl.publicCardUrl(profile.slug)}',
                ),
              ),
              onAppleWallet: walletService.isMobile
                  ? () => walletService.addToAppleWallet(profile.slug)
                  : null,
              onGoogleWallet: walletService.isMobile
                  ? () => walletService.addToGoogleWallet(profile.slug)
                  : null,
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
