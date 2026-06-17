import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Firebase Cloud Messaging integration for iOS and Android.
///
/// On web, FCM is skipped. Requires Firebase config files on mobile.
class FcmService {
  final Future<void> Function(String token, {String platform}) onToken;

  FcmService({required this.onToken});

  bool get _isMobile =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  String get _platform =>
      defaultTargetPlatform == TargetPlatform.android ? 'android' : 'ios';

  Future<void> initialize() async {
    if (!_isMobile) return;

    final messaging = FirebaseMessaging.instance;

    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    final token = await messaging.getToken();
    if (token != null) {
      await onToken(token, platform: _platform);
    }

    messaging.onTokenRefresh.listen((token) {
      onToken(token, platform: _platform);
    });
  }
}
