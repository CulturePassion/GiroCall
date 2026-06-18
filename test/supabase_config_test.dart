import 'package:flutter_test/flutter_test.dart';
import 'package:girocall/core/supabase_config.dart';

void main() {
  group('SupabaseConfig.fromEnvironment', () {
    test('treats empty credentials as placeholder', () {
      final config = SupabaseConfig.fromEnvironment(url: '', anonKey: '');
      expect(config.isConfigured, isFalse);
      expect(config.url, SupabaseConfig.placeholderUrl);
      expect(config.anonKey, SupabaseConfig.placeholderAnonKey);
    });

    test('treats .env.example template values as placeholder', () {
      final config = SupabaseConfig.fromEnvironment(
        url: 'https://gtvpsukmmjhszpopulfe.supabase.co',
        anonKey: 'your-publishable-anon-key',
      );
      expect(config.isConfigured, isFalse);
    });

    test('accepts real-looking credentials', () {
      final config = SupabaseConfig.fromEnvironment(
        url: 'https://gtvpsukmmjhszpopulfe.supabase.co',
        anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.test.signature',
      );
      expect(config.isConfigured, isTrue);
    });
  });
}