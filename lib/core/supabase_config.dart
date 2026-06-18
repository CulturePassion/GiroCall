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

  /// Values copied from [.env.example] that must be replaced before running.
  static const templateAnonKeys = {
    'your-publishable-anon-key',
    'your-anon-key',
    'your_supabase_anon_key',
  };

  static const templateUrls = {
    'https://your-project.supabase.co',
    'https://your-project-ref.supabase.co',
  };

  bool get isConfigured => !isPlaceholder;

  static bool isPlaceholderValue({
    required String url,
    required String anonKey,
  }) {
    if (url.isEmpty || anonKey.isEmpty) return true;
    if (url == placeholderUrl || anonKey == placeholderAnonKey) return true;
    if (templateUrls.contains(url.trim())) return true;
    if (templateAnonKeys.contains(anonKey.trim())) return true;
    return false;
  }

  static SupabaseConfig fromEnvironment({
    required String url,
    required String anonKey,
  }) {
    final isPlaceholder = isPlaceholderValue(url: url, anonKey: anonKey);
    final resolvedUrl = url.isNotEmpty ? url : placeholderUrl;
    final resolvedAnonKey = anonKey.isNotEmpty ? anonKey : placeholderAnonKey;

    return SupabaseConfig(
      url: resolvedUrl,
      anonKey: resolvedAnonKey,
      isPlaceholder: isPlaceholder,
    );
  }
}
