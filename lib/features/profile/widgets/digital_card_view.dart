import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/design/colors.dart';
import '../../../core/design/spacing.dart';
import '../../../core/design/tokens.dart';
import '../../../core/utils/card_url.dart';
import '../../../shared/models/user_profile.dart';

enum DigitalCardVariant { public, owner }

/// Link-in-bio style digital business card — shared by profile, my card, and public pages.
class DigitalCardView extends StatelessWidget {
  final UserProfile profile;
  final DigitalCardVariant variant;
  final bool showQr;
  final VoidCallback? onSaveContact;
  final VoidCallback? onAppleWallet;
  final VoidCallback? onGoogleWallet;
  final VoidCallback? onShare;
  final VoidCallback? onEdit;

  const DigitalCardView({
    super.key,
    required this.profile,
    this.variant = DigitalCardVariant.public,
    this.showQr = true,
    this.onSaveContact,
    this.onAppleWallet,
    this.onGoogleWallet,
    this.onShare,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final cardUrl = CardUrl.publicCardUrl(profile.slug);
    final cardPath = CardUrl.publicCardPath(profile.slug);
    final subtitle = [
      if (profile.title != null && profile.title!.isNotEmpty) profile.title!,
      if (profile.company != null && profile.company!.isNotEmpty)
        profile.company!,
    ].join(' · ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _HeroHeader(
          profile: profile,
          subtitle: subtitle,
          cardPath: cardPath,
          isOwner: variant == DigitalCardVariant.owner,
        ),
        const SizedBox(height: AppSpacing.sm),
        if (profile.phone != null && profile.phone!.isNotEmpty)
          _LinkButton(
            icon: Icons.phone_outlined,
            label: profile.phone!,
            color: AppColors.main,
            onTap: () => _launchUri('tel:${profile.phone}'),
          ),
        if (profile.email != null && profile.email!.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          _LinkButton(
            icon: Icons.email_outlined,
            label: profile.email!,
            color: AppColors.secondaryBlue,
            onTap: () => _launchUri('mailto:${profile.email}'),
          ),
        ],
        if (profile.formattedAddress != null) ...[
          const SizedBox(height: AppSpacing.xs),
          _LinkButton(
            icon: Icons.location_on_outlined,
            label: profile.formattedAddress!,
            color: AppColors.premiumPurple,
            onTap: () => _launchMaps(profile.formattedAddress!),
          ),
        ],
        ...profile.socialLinks.map(
          (link) => Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: _LinkButton(
              icon: _iconFor(link.platform),
              label: link.label,
              color: _colorFor(link.platform),
              onTap: () => _launchUri(link.url),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (onSaveContact != null)
          _ActionButton(
            icon: Icons.person_add_alt_1_outlined,
            label: 'Save to contacts (.vcf)',
            filled: true,
            onTap: onSaveContact!,
          ),
        if (variant == DigitalCardVariant.owner && profile.isPublic) ...[
          const SizedBox(height: AppSpacing.xs),
          _ActionButton(
            icon: Icons.content_copy_outlined,
            label: 'Copy link',
            onTap: () => _copyLink(context, cardUrl),
          ),
        ],
        if (onShare != null) ...[
          const SizedBox(height: AppSpacing.xs),
          _ActionButton(
            icon: Icons.share_outlined,
            label: 'Share card link',
            onTap: onShare!,
          ),
        ],
        if (onEdit != null) ...[
          const SizedBox(height: AppSpacing.xs),
          _ActionButton(
            icon: Icons.edit_outlined,
            label: 'Edit card',
            onTap: onEdit!,
          ),
        ],
        if (showQr && profile.isPublic) ...[
          const SizedBox(height: AppSpacing.lg),
          _QrSection(cardUrl: cardUrl, cardPath: cardPath),
        ],
        if (onAppleWallet != null || onGoogleWallet != null) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            'Digital wallet',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          if (onAppleWallet != null)
            _ActionButton(
              icon: Icons.wallet_outlined,
              label: 'Add to Apple Wallet',
              onTap: onAppleWallet!,
            ),
          if (onGoogleWallet != null) ...[
            const SizedBox(height: AppSpacing.xs),
            _ActionButton(
              icon: Icons.account_balance_wallet_outlined,
              label: 'Add to Google Wallet',
              onTap: onGoogleWallet!,
            ),
          ],
        ],
        if (variant == DigitalCardVariant.public) ...[
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Made with GiroCall',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ],
    );
  }

  Future<void> _launchUri(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchMaps(String address) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _copyLink(BuildContext context, String url) {
    Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Link copied to clipboard')),
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
      case 'website':
        return Icons.public;
      default:
        return Icons.link;
    }
  }

  Color _colorFor(String platform) {
    switch (platform) {
      case 'linkedin':
        return AppColors.royalBlue;
      case 'twitter':
        return AppColors.warmBlue;
      case 'instagram':
        return AppColors.softPink;
      case 'facebook':
        return AppColors.warmBlue;
      case 'tiktok':
        return AppColors.persianBlue;
      case 'youtube':
        return AppColors.error;
      case 'website':
        return AppColors.main;
      default:
        return AppColors.warmGray;
    }
  }
}

class _HeroHeader extends StatelessWidget {
  final UserProfile profile;
  final String subtitle;
  final String cardPath;
  final bool isOwner;

  const _HeroHeader({
    required this.profile,
    required this.subtitle,
    required this.cardPath,
    required this.isOwner,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppTokens.radiusXl),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 48,
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
                        fontSize: 36,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            profile.displayName,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xxs),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
            ),
          ],
          if (profile.bio != null && profile.bio!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              profile.bio!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.92),
                    height: 1.5,
                  ),
            ),
          ],
          if (profile.isPublic || isOwner) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xxs,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    profile.isPublic ? Icons.link : Icons.lock_outline,
                    size: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    profile.isPublic
                        ? cardPath
                        : 'Private — turn on sharing to get a link',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LinkButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _LinkButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 14,
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppColors.textSecondary.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool filled;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ],
    );

    if (filled) {
      return FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.main,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        child: child,
      );
    }

    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: BorderSide(color: Colors.white.withValues(alpha: 0.65)),
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
      ),
      child: child,
    );
  }
}

class _QrSection extends StatelessWidget {
  final String cardUrl;
  final String cardPath;

  const _QrSection({required this.cardUrl, required this.cardPath});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
      ),
      child: Column(
        children: [
          Text(
            'Scan to connect',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          QrImageView(
            data: cardUrl,
            version: QrVersions.auto,
            size: 160,
            eyeStyle: const QrEyeStyle(
              eyeShape: QrEyeShape.square,
              color: AppColors.primaryTeal,
            ),
            dataModuleStyle: const QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.square,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          SelectableText(
            cardPath,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
