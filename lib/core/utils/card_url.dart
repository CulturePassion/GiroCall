import '../constants.dart';

/// Builds shareable URLs for public digital business cards.
class CardUrl {
  const CardUrl._();

  static String publicCardUrl(String slug, {String? baseUrl}) {
    final base =
        (baseUrl ?? Constants.appBaseUrl).replaceAll(RegExp(r'/+$'), '');
    return '$base/me/$slug';
  }

  /// Short display form shown in UI chips and copy fields.
  static String publicCardPath(String slug) => 'girocall.com/me/$slug';

  static String walletPassUrl({
    required String supabaseUrl,
    required String slug,
    required String platform,
  }) {
    final base = supabaseUrl.replaceAll(RegExp(r'/+$'), '');
    return '$base/functions/v1/wallet-pass?slug=$slug&platform=$platform';
  }
}