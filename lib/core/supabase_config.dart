/// Runtime Supabase configuration resolved in [main].
class SupabaseConfig {
  const SupabaseConfig({
    required this.url,
    required this.anonKey,
    required this.isPlaceholder,
  });

  final String url;
  final String anonKey;
  final bool isPlaceholder;

  static const placeholderUrl = 'https://dummy.supabase.co';
  static const placeholderAnonKey = 'dummy-anon-key';

  bool get isConfigured => !isPlaceholder;

  static SupabaseConfig fromEnvironment({
    required String url,
    required String anonKey,
  }) {
    final resolvedUrl = url.isNotEmpty ? url : placeholderUrl;
    final resolvedAnonKey = anonKey.isNotEmpty ? anonKey : placeholderAnonKey;

    return SupabaseConfig(
      url: resolvedUrl,
      anonKey: resolvedAnonKey,
      isPlaceholder: url.isEmpty || anonKey.isEmpty,
    );
  }
}
