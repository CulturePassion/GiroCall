import '../../shared/models/contact.dart';
import '../../shared/models/user_profile.dart';
import 'card_url.dart';

/// Builds vCard 3.0 content for saving/sharing digital business cards.
class VCardBuilder {
  const VCardBuilder._();

  static String fromProfile(UserProfile profile, {String? cardUrl}) {
    final resolvedCardUrl = cardUrl ?? CardUrl.publicCardUrl(profile.slug);
    final buffer = StringBuffer()
      ..writeln('BEGIN:VCARD')
      ..writeln('VERSION:3.0')
      ..writeln('FN:${_escape(profile.displayName)}')
      ..writeln('UID:girocall-${profile.slug}@girocall.com');

    if (profile.title != null && profile.title!.isNotEmpty) {
      buffer.writeln('TITLE:${_escape(profile.title!)}');
    }
    if (profile.company != null && profile.company!.isNotEmpty) {
      buffer.writeln('ORG:${_escape(profile.company!)}');
    }
    if (profile.phone != null && profile.phone!.isNotEmpty) {
      buffer.writeln('TEL;TYPE=CELL:${_escape(profile.phone!)}');
    }
    if (profile.email != null && profile.email!.isNotEmpty) {
      buffer.writeln('EMAIL;TYPE=INTERNET:${_escape(profile.email!)}');
    }
    if (profile.website != null && profile.website!.isNotEmpty) {
      buffer.writeln('URL:${_escape(profile.website!)}');
    }
    buffer.writeln('URL;TYPE=GIROCALL:${_escape(resolvedCardUrl)}');

    final address = profile.formattedAddress;
    if (address != null) {
      buffer.writeln(
        'ADR;TYPE=WORK:;;${_escape(profile.addressLine1 ?? '')};'
        '${_escape(profile.city ?? '')};${_escape(profile.state ?? '')};'
        '${_escape(profile.postalCode ?? '')};${_escape(profile.country ?? '')}',
      );
    }

    if (profile.bio != null && profile.bio!.isNotEmpty) {
      buffer.writeln('NOTE:${_escape(profile.bio!)}');
    }

    for (final link in profile.socialLinks) {
      if (link.platform != 'website') {
        buffer.writeln(
            'URL;TYPE=${link.platform.toUpperCase()}:${_escape(link.url)}');
      }
    }

    buffer.writeln('END:VCARD');
    return buffer.toString();
  }

  static String fromContact(Contact contact) {
    final buffer = StringBuffer()
      ..writeln('BEGIN:VCARD')
      ..writeln('VERSION:3.0')
      ..writeln('FN:${_escape(contact.name)}');

    if (contact.firstName != null ||
        contact.lastName != null ||
        contact.name.isNotEmpty) {
      buffer.writeln(
        'N:${_escape(contact.lastName ?? '')};'
        '${_escape(contact.firstName ?? contact.name.split(' ').first)};;;',
      );
    }
    if (contact.jobTitle != null && contact.jobTitle!.isNotEmpty) {
      buffer.writeln('TITLE:${_escape(contact.jobTitle!)}');
    }
    if (contact.company != null && contact.company!.isNotEmpty) {
      buffer.writeln('ORG:${_escape(contact.company!)}');
    }
    if (contact.phone.isNotEmpty) {
      buffer.writeln('TEL;TYPE=CELL:${_escape(contact.phone)}');
    }
    if (contact.secondaryPhone?.isNotEmpty == true) {
      buffer.writeln('TEL;TYPE=WORK:${_escape(contact.secondaryPhone!)}');
    }
    if (contact.email != null && contact.email!.isNotEmpty) {
      buffer.writeln('EMAIL;TYPE=INTERNET:${_escape(contact.email!)}');
    }
    if (contact.website != null && contact.website!.isNotEmpty) {
      buffer.writeln('URL:${_escape(contact.website!)}');
    }
    if (contact.formattedAddress != null) {
      buffer.writeln(
        'ADR;TYPE=HOME:;;${_escape(contact.addressLine1 ?? '')};'
        '${_escape(contact.city ?? '')};${_escape(contact.state ?? '')};'
        '${_escape(contact.postalCode ?? '')};${_escape(contact.country ?? '')}',
      );
    }
    if (contact.birthday != null) {
      final b = contact.birthday!;
      final y = b.year.toString().padLeft(4, '0');
      final m = b.month.toString().padLeft(2, '0');
      final d = b.day.toString().padLeft(2, '0');
      buffer.writeln('BDAY:$y$m$d');
    }
    if (contact.notes != null && contact.notes!.isNotEmpty) {
      buffer.writeln('NOTE:${_escape(contact.notes!)}');
    }

    buffer.writeln('END:VCARD');
    return buffer.toString();
  }

  static String _escape(String value) {
    return value
        .replaceAll('\\', '\\\\')
        .replaceAll(';', '\\;')
        .replaceAll(',', '\\,')
        .replaceAll('\n', '\\n');
  }
}
