import 'dart:convert';

import '../../shared/models/contact.dart';
import '../../shared/widgets/phone_formatter.dart';

/// Parses vCard 3.0/4.0 payloads from QR scans and shared files.
class VCardParser {
  const VCardParser._();

  static ContactDraft? parse(String raw, {required String userId}) {
    final unfolded = raw
        .replaceAll('\r\n ', '')
        .replaceAll('\n ', '')
        .trim();

    if (!unfolded.toUpperCase().contains('BEGIN:VCARD')) {
      return _parseGiroCallPayload(unfolded, userId: userId);
    }

    final lines = unfolded.split(RegExp(r'\r?\n'));
    String? fn;
    String? firstName;
    String? lastName;
    String? phone;
    String? secondaryPhone;
    String? email;
    String? company;
    String? jobTitle;
    String? website;
    String? notes;
    String? addressLine1;
    String? city;
    String? state;
    String? postalCode;
    String? country;
    DateTime? birthday;

    for (final line in lines) {
      final colon = line.indexOf(':');
      if (colon <= 0) continue;
      final keyPart = line.substring(0, colon).toUpperCase();
      final value = _unescape(line.substring(colon + 1).trim());
      if (value.isEmpty) continue;

      final key = keyPart.split(';').first;
      switch (key) {
        case 'FN':
          fn = value;
        case 'N':
          final parts = value.split(';');
          if (parts.length > 1) lastName = parts[0].trim().isEmpty ? null : parts[0];
          if (parts.length > 2) firstName = parts[1].trim().isEmpty ? null : parts[1];
        case 'TEL':
          final normalized = PhoneFormatter.normalize(value);
          if (PhoneFormatter.looksValid(normalized)) {
            if (phone == null) {
              phone = normalized;
            } else if (secondaryPhone == null) {
              secondaryPhone = normalized;
            }
          }
        case 'EMAIL':
          email ??= value;
        case 'ORG':
          company ??= value;
        case 'TITLE':
          jobTitle ??= value;
        case 'URL':
          website ??= value;
        case 'NOTE':
          notes ??= value;
        case 'BDAY':
          birthday = _parseBirthday(value);
        case 'ADR':
          final parts = value.split(';');
          if (parts.length > 2 && parts[2].trim().isNotEmpty) {
            addressLine1 = parts[2];
          }
          if (parts.length > 3 && parts[3].trim().isNotEmpty) city = parts[3];
          if (parts.length > 4 && parts[4].trim().isNotEmpty) state = parts[4];
          if (parts.length > 5 && parts[5].trim().isNotEmpty) {
            postalCode = parts[5];
          }
          if (parts.length > 6 && parts[6].trim().isNotEmpty) country = parts[6];
      }
    }

    phone ??= '';
    if (!PhoneFormatter.looksValid(phone)) return null;

    final displayName = Contact.buildDisplayName(
      firstName: firstName,
      lastName: lastName,
      fallback: fn,
    );

    return ContactDraft(
      userId: userId,
      name: displayName,
      phone: phone,
      firstName: firstName,
      lastName: lastName,
      email: email,
      company: company,
      jobTitle: jobTitle,
      birthday: birthday,
      secondaryPhone: secondaryPhone,
      website: website,
      notes: notes,
      addressLine1: addressLine1,
      city: city,
      state: state,
      postalCode: postalCode,
      country: country,
    );
  }

  static ContactDraft? _parseGiroCallPayload(String raw, {required String userId}) {
    if (!raw.startsWith('{')) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final phone = PhoneFormatter.normalize(map['phone'] as String? ?? '');
      if (!PhoneFormatter.looksValid(phone)) return null;
      return ContactDraft(
        userId: userId,
        name: map['name'] as String? ?? 'Unknown',
        phone: phone,
        firstName: map['first_name'] as String?,
        lastName: map['last_name'] as String?,
        email: map['email'] as String?,
        company: map['company'] as String?,
        jobTitle: map['job_title'] as String?,
        website: map['website'] as String?,
      );
    } catch (_) {
      return null;
    }
  }

  static DateTime? _parseBirthday(String value) {
    final cleaned = value.replaceAll('-', '');
    if (cleaned.length == 8) {
      final year = int.tryParse(cleaned.substring(0, 4));
      final month = int.tryParse(cleaned.substring(4, 6));
      final day = int.tryParse(cleaned.substring(6, 8));
      if (year != null && month != null && day != null) {
        return DateTime(year, month, day);
      }
    }
    return DateTime.tryParse(value);
  }

  static String _unescape(String value) {
    return value
        .replaceAll(r'\n', '\n')
        .replaceAll(r'\,', ',')
        .replaceAll(r'\;', ';')
        .replaceAll(r'\\', r'\');
  }
}

/// Parsed contact data before persistence.
class ContactDraft {
  final String userId;
  final String name;
  final String phone;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? company;
  final String? jobTitle;
  final DateTime? birthday;
  final String? secondaryPhone;
  final String? website;
  final String? notes;
  final String? addressLine1;
  final String? city;
  final String? state;
  final String? postalCode;
  final String? country;

  const ContactDraft({
    required this.userId,
    required this.name,
    required this.phone,
    this.firstName,
    this.lastName,
    this.email,
    this.company,
    this.jobTitle,
    this.birthday,
    this.secondaryPhone,
    this.website,
    this.notes,
    this.addressLine1,
    this.city,
    this.state,
    this.postalCode,
    this.country,
  });

  Contact toContact() {
    return Contact(
      userId: userId,
      name: name,
      phone: phone,
      firstName: firstName,
      lastName: lastName,
      email: email,
      company: company,
      jobTitle: jobTitle,
      birthday: birthday,
      secondaryPhone: secondaryPhone,
      website: website,
      notes: notes,
      addressLine1: addressLine1,
      city: city,
      state: state,
      postalCode: postalCode,
      country: country,
    );
  }
}