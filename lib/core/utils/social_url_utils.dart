/// Canonical URL prefixes used when saving — never shown in form fields.
abstract final class SocialUrlPrefixes {
  static const linkedin = 'https://www.linkedin.com/in/';
  static const twitter = 'https://www.twitter.com/';
  static const instagram = 'https://www.instagram.com/';
  static const facebook = 'https://www.facebook.com/';
  static const tiktok = 'https://www.tiktok.com/@';
  static const youtube = 'https://www.youtube.com/@';
}

/// Handle-only value for editing (strips stored URLs down to username/path).
String socialHandleForField(String? storedUrl, String prefix) {
  if (storedUrl == null || storedUrl.trim().isEmpty) return '';
  return _prepareSocialHandle(storedUrl, knownPrefix: prefix);
}

/// Builds a canonical full URL from a handle or pasted link.
String? normalizePrefixedUrl(String input, String prefix) {
  final handle = _prepareSocialHandle(input, knownPrefix: prefix);
  if (handle.isEmpty) return null;
  return '$prefix$handle';
}

/// Website — store canonical URL; field shows domain only.
String? normalizeWebsiteUrl(String input) {
  final trimmed = input.trim();
  if (trimmed.isEmpty) return null;

  if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
    final uri = Uri.tryParse(trimmed);
    if (uri != null && uri.host.isNotEmpty) {
      return 'https://${uri.host}';
    }
  }

  final domain = websiteForField(trimmed);
  if (domain.isEmpty) return null;

  if (domain.startsWith('www.')) {
    return 'https://$domain';
  }

  final labels = domain.split('.');
  if (labels.length == 2) {
    return 'https://www.$domain';
  }

  return 'https://$domain';
}

String websiteForField(String? storedUrl) {
  if (storedUrl == null || storedUrl.trim().isEmpty) return '';

  var value = storedUrl.trim();
  final lower = value.toLowerCase();

  if (lower.startsWith('https://www.')) {
    value = value.substring('https://www.'.length);
  } else if (lower.startsWith('http://www.')) {
    value = value.substring('http://www.'.length);
  } else if (lower.startsWith('https://')) {
    value = value.substring('https://'.length);
  } else if (lower.startsWith('http://')) {
    value = value.substring('http://'.length);
  }

  return value.split('/').first;
}

String _prepareSocialHandle(String input, {required String knownPrefix}) {
  final trimmed = input.trim();
  if (trimmed.isEmpty) return '';

  final lower = trimmed.toLowerCase();
  final prefixLower = knownPrefix.toLowerCase();

  if (lower.startsWith(prefixLower)) {
    return _trimTrailingSlash(trimmed.substring(knownPrefix.length));
  }

  for (final variant in _prefixVariants(knownPrefix)) {
    if (lower.startsWith(variant)) {
      return _trimTrailingSlash(trimmed.substring(variant.length));
    }
  }

  if (lower.startsWith('http://') || lower.startsWith('https://')) {
    final uri = Uri.tryParse(trimmed);
    if (uri != null) {
      return _handleFromUri(uri);
    }
  }

  return trimmed.startsWith('@') ? trimmed.substring(1) : trimmed;
}

String _handleFromUri(Uri uri) {
  final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
  if (segments.isEmpty) {
    final host = uri.host;
    return host.startsWith('www.') ? host.substring(4) : host;
  }

  if (segments.length >= 2 && segments[segments.length - 2] == 'in') {
    return segments.last;
  }

  final last = segments.last;
  return last.startsWith('@') ? last.substring(1) : last;
}

String _trimTrailingSlash(String value) {
  return value.endsWith('/') ? value.substring(0, value.length - 1) : value;
}

Iterable<String> _prefixVariants(String prefix) {
  final withoutWww = prefix.replaceFirst('https://www.', 'https://');
  return {
    withoutWww,
    prefix.replaceFirst('https://', 'http://'),
    prefix.replaceFirst('https://www.twitter.com/', 'https://x.com/'),
    prefix.replaceFirst('https://www.twitter.com/', 'https://www.x.com/'),
  };
}
