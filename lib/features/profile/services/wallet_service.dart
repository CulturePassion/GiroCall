import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/utils/card_url.dart';

/// Opens wallet pass endpoints for Apple Wallet and Google Wallet.
class WalletService {
  const WalletService({required this.supabaseUrl});

  final String supabaseUrl;

  Future<bool> addToAppleWallet(String slug) {
    return _openWallet(slug, 'apple');
  }

  Future<bool> addToGoogleWallet(String slug) {
    return _openWallet(slug, 'google');
  }

  Future<bool> _openWallet(String slug, String platform) async {
    final url = CardUrl.walletPassUrl(
      supabaseUrl: supabaseUrl,
      slug: slug,
      platform: platform,
    );
    final uri = Uri.parse(url);
    if (!await canLaunchUrl(uri)) return false;
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  bool get isMobile => !kIsWeb;
}
