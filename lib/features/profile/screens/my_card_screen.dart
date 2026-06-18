import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/design/colors.dart';
import '../../../core/supabase_provider.dart';
import '../../../core/utils/card_url.dart';
import '../../../core/utils/screen_padding.dart';
import '../../../core/utils/supabase_error_message.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/primary_button.dart';
import '../providers/profile_notifier.dart';
import '../services/contact_save_service.dart';
import '../services/wallet_service.dart';
import '../widgets/digital_card_view.dart';

class MyCardScreen extends ConsumerWidget {
  const MyCardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileNotifierProvider);
    final supabaseUrl = ref.watch(supabaseConfigProvider).url;
    final walletService = WalletService(supabaseUrl: supabaseUrl);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppScaffold(
      title: 'My Digital Card',
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

          return SingleChildScrollView(
            padding: ScreenPadding.all(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!profile.isPublic)
                  Card(
                    color: isDark
                        ? AppColors.accentCoral.withValues(alpha: 0.15)
                        : Colors.amber.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.visibility_off_outlined,
                            color: isDark
                                ? AppColors.accentCoral
                                : Colors.amber.shade900,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Your card is private. Turn on public sharing in Edit to get a QR code and link.',
                              style: TextStyle(
                                color: isDark
                                    ? AppColors.accentCoral
                                    : Colors.amber.shade900,
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                DigitalCardView(
                  profile: profile,
                  showQr: profile.isPublic,
                  onSaveContact: () =>
                      const ContactSaveService().saveProfileContact(profile),
                  onShare: profile.isPublic
                      ? () => SharePlus.instance.share(
                            ShareParams(
                              text:
                                  'Connect with ${profile.displayName}: ${CardUrl.publicCardUrl(profile.slug)}',
                            ),
                          )
                      : null,
                  onAppleWallet: profile.isPublic && walletService.isMobile
                      ? () => walletService.addToAppleWallet(profile.slug)
                      : null,
                  onGoogleWallet: profile.isPublic && walletService.isMobile
                      ? () => walletService.addToGoogleWallet(profile.slug)
                      : null,
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  label: 'Edit my card',
                  icon: Icons.edit_outlined,
                  onPressed: () => context.push('/profile/edit'),
                ),
              ],
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
