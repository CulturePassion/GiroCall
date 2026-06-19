import 'package:flutter_test/flutter_test.dart';
import 'package:girocall/core/utils/social_url_utils.dart';

void main() {
  group('socialHandleForField', () {
    test('strips known prefix to show handle only', () {
      expect(
        socialHandleForField(
          'https://www.instagram.com/janedoe',
          SocialUrlPrefixes.instagram,
        ),
        'janedoe',
      );
    });

    test('returns empty for null', () {
      expect(socialHandleForField(null, SocialUrlPrefixes.facebook), '');
    });

    test('extracts handle from full URL', () {
      expect(
        socialHandleForField(
          'https://www.instagram.com/janedoe/',
          SocialUrlPrefixes.instagram,
        ),
        'janedoe',
      );
    });
  });

  group('normalizePrefixedUrl', () {
    test('builds full URL from handle', () {
      expect(
        normalizePrefixedUrl('janedoe', SocialUrlPrefixes.instagram),
        'https://www.instagram.com/janedoe',
      );
    });

    test('normalizes pasted full URL to canonical prefix', () {
      expect(
        normalizePrefixedUrl(
          'https://x.com/janedoe',
          SocialUrlPrefixes.twitter,
        ),
        'https://www.twitter.com/janedoe',
      );
    });

    test('returns null for empty input', () {
      expect(normalizePrefixedUrl('  ', SocialUrlPrefixes.tiktok), isNull);
    });
  });

  group('normalizeWebsiteUrl', () {
    test('prefixes domain-only input', () {
      expect(
        normalizeWebsiteUrl('example.com'),
        'https://www.example.com',
      );
    });

    test('normalizes pasted website to host only', () {
      expect(
        normalizeWebsiteUrl('https://blog.example.com/about'),
        'https://blog.example.com',
      );
    });
  });

  group('websiteForField', () {
    test('strips https://www. prefix for editing', () {
      expect(
        websiteForField('https://www.example.com'),
        'example.com',
      );
    });
  });
}
