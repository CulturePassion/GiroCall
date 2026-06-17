import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../features/notifications/providers/fcm_provider.dart';

bool _firebaseInitialized = false;

/// Initializes Firebase + FCM when running on a mobile device with config present.
Future<void> initializeFirebaseMessaging(WidgetRef ref) async {
  if (kIsWeb) return;

  final session = Supabase.instance.client.auth.currentSession;
  if (session == null) return;

  try {
    if (!_firebaseInitialized) {
      await Firebase.initializeApp();
      _firebaseInitialized = true;
    }
    await ref.read(fcmServiceProvider).initialize();
  } catch (_) {
    // Firebase config files are optional until mobile push is set up.
  }
}
