import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/fcm_service.dart';
import 'fcm_token_repository_provider.dart';

final fcmServiceProvider = Provider<FcmService>((ref) {
  return FcmService(
    onToken: (token, {String platform = 'unknown'}) async {
      await ref
          .read(fcmTokenRepositoryProvider)
          .saveToken(token, platform: platform);
    },
  );
});
