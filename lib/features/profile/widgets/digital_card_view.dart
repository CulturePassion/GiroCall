import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/app_colors.dart';
import '../../../core/utils/card_url.dart';
import '../../../shared/models/user_profile.dart';

class DigitalCardView extends StatelessWidget {
  final UserProfile profile;
  final bool showQr;
  final VoidCallback? onSaveContact;
  final VoidCallback? onAppleWallet;
  final VoidCallback? onGoogleWallet;
  final VoidCallback? onShare;

  const DigitalCardView({
    super.key,
    required this.profile,
    this.showQr = true,
    this.onSaveContact,
    this.onAppleWallet,
    this.onGoogleWallet,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final cardUrl = CardUrl.publicCardUrl(profile.slug);
    final subtitle = [
      if (profile.title != null && profile.title!.isNotEmpty) profile.title!,
      if (profile.company != null && profile.company!.isNotEmpty)
        profile.company!,
    ].join(' · ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side:
                BorderSide(color: AppColors.primaryTeal.withValues(alpha: 0.2)),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryTeal.withValues(alpha: 0.08),
                  AppColors.accentCoral.withValues(alpha: 0.06),
                ],
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor: AppColors.primaryTeal,
                  backgroundImage: profile.avatarUrl != null
                      ? NetworkImage(profile.avatarUrl!)
                      : null,
                  child: profile.avatarUrl == null
                      ? Text(
                          profile.displayName.isNotEmpty
                              ? profile.displayName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            fontSize: 32,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  profile.displayName,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
                if (profile.bio != null && profile.bio!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    profile.bio!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (profile.hasContactInfo) _InfoSection(profile: profile),
        if (profile.socialLinks.isNotEmpty) ...[
          const SizedBox(height: 16),
          _SocialSection(links: profile.socialLinks),
        ],
        if (showQr && profile.isPublic) ...[
          const SizedBox(height: 24),
          Text(
            'Scan to connect',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: AppColors.primaryTeal.withValues(alpha: 0.2)),
              ),
              child: QrImageView(
                data: cardUrl,
                version: QrVersions.auto,
                size: 180,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: AppColors.primaryTeal,
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SelectableText(
            cardUrl,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
        const SizedBox(height: 24),
        if (onSaveContact != null)
          FilledButton.icon(
            onPressed: onSaveContact,
            icon: const Icon(Icons.person_add_alt_1_outlined),
            label: const Text('Save contact'),
          ),
        if (onShare != null) ...[
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onShare,
            icon: const Icon(Icons.share_outlined),
            label: const Text('Share card link'),
          ),
        ],
        if (onAppleWallet != null || onGoogleWallet != null) ...[
          const SizedBox(height: 20),
          Text(
            'Digital wallet',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          if (onAppleWallet != null)
            OutlinedButton.icon(
              onPressed: onAppleWallet,
              icon: const Icon(Icons.wallet_outlined),
              label: const Text('Add to Apple Wallet'),
            ),
          if (onGoogleWallet != null) ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: onGoogleWallet,
              icon: const Icon(Icons.account_balance_wallet_outlined),
              label: const Text('Add to Google Wallet'),
            ),
          ],
        ],
      ],
    );
  }
}

class _InfoSection extends StatelessWidget {
  final UserProfile profile;

  const _InfoSection({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (profile.phone != null && profile.phone!.isNotEmpty)
              _InfoRow(icon: Icons.phone_outlined, text: profile.phone!),
            if (profile.email != null && profile.email!.isNotEmpty)
              _InfoRow(icon: Icons.email_outlined, text: profile.email!),
            if (profile.formattedAddress != null)
              _InfoRow(
                icon: Icons.location_on_outlined,
                text: profile.formattedAddress!,
              ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryTeal, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _SocialSection extends StatelessWidget {
  final List<({String label, String url, String platform})> links;

  const _SocialSection({required this.links});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: links
              .map(
                (link) => ListTile(
                  leading: Icon(_iconFor(link.platform),
                      color: AppColors.secondaryBlue),
                  title: Text(link.label),
                  trailing: const Icon(Icons.open_in_new, size: 18),
                  onTap: () => launchUrl(
                    Uri.parse(link.url),
                    mode: LaunchMode.externalApplication,
                  ),
                  dense: true,
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  IconData _iconFor(String platform) {
    switch (platform) {
      case 'linkedin':
        return Icons.work_outline;
      case 'twitter':
        return Icons.alternate_email;
      case 'instagram':
        return Icons.camera_alt_outlined;
      case 'facebook':
        return Icons.facebook;
      case 'tiktok':
        return Icons.music_note_outlined;
      case 'youtube':
        return Icons.play_circle_outline;
      default:
        return Icons.link;
    }
  }
}
