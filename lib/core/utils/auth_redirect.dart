import 'package:flutter/foundation.dart';

import '../constants.dart';

/// Redirect URL for Supabase auth emails (password reset, magic links).
String authRedirectUrl() {
  if (kIsWeb) {
    final origin = Uri.base.origin;
    if (origin.isNotEmpty && origin != 'null') {
      return origin;
    }
  }
  return Constants.appBaseUrl.replaceAll(RegExp(r'/+$'), '');
}
