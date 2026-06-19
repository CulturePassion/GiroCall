import 'package:flutter/foundation.dart';

import '../constants.dart';

/// Redirect URL for Supabase auth emails (sign-up confirm, password reset).
String authRedirectUrl() {
  final configured = Constants.webAuthRedirectUrl.trim();
  if (configured.isNotEmpty) {
    return configured.replaceAll(RegExp(r'/+$'), '');
  }

  if (kIsWeb) {
    final origin = Uri.base.origin;
    if (origin.isNotEmpty && origin != 'null') {
      return origin;
    }
  }

  return Constants.appBaseUrl.replaceAll(RegExp(r'/+$'), '');
}
