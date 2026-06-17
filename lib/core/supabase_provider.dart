import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_config.dart';

/// Resolved Supabase credentials for the current app session.
final supabaseConfigProvider = Provider<SupabaseConfig>((ref) {
  throw UnimplementedError(
    'supabaseConfigProvider must be overridden in main()',
  );
});

/// Provides the Supabase client instance.
///
/// Call [initializeSupabase] before running the app, typically in main().
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Current authenticated user stream.
final authUserProvider = StreamProvider<AuthState?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client.auth.onAuthStateChange;
});

/// Initializes Supabase with URL and anon key from environment.
Future<void> initializeSupabase({
  required String url,
  required String anonKey,
}) async {
  await Supabase.initialize(
    url: url,
    publishableKey: anonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
      detectSessionInUri: kIsWeb,
    ),
  );
}
