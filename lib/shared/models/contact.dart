import 'package:flutter/foundation.dart';

import 'contact_tag.dart';

/// Represents a person the user wants to stay in touch with.
@immutable
class Contact {
  final String? id;
  final String userId;
  final String name;
  final String phone;
  final String? photoUrl;
  final String? notes;
  final ContactTag? tag;
  final int targetFrequencyDays;
  final DateTime? lastCalledAt;
  final int? relationshipScore;
  final DateTime? createdAt;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? company;
  final String? jobTitle;
  final DateTime? birthday;
  final String? secondaryPhone;
  final String? website;
  final String? addressLine1;
  final String? addressLine2;
  final String? city;
  final String? state;
  final String? postalCode;
  final String? country;
  final String? deviceNativeId;
  final bool syncToDevice;
  final DateTime? lastDeviceSyncAt;

  const Contact({
    this.id,
    required this.userId,
    required this.name,
    required this.phone,
    this.photoUrl,
    this.notes,
    this.tag,
    this.targetFrequencyDays = 30,
    this.lastCalledAt,
    this.relationshipScore,
    this.createdAt,
    this.firstName,
    this.lastName,
    this.email,
    this.company,
    this.jobTitle,
    this.birthday,
    this.secondaryPhone,
    this.website,
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.state,
    this.postalCode,
    this.country,
    this.deviceNativeId,
    this.syncToDevice = true,
    this.lastDeviceSyncAt,
  });

  /// Builds a display name from first/last name parts with optional fallback.
  static String buildDisplayName({
    String? firstName,
    String? lastName,
    String? fallback,
  }) {
    final first = firstName?.trim() ?? '';
    final last = lastName?.trim() ?? '';
    final combined = [first, last].where((s) => s.isNotEmpty).join(' ');
    if (combined.isNotEmpty) return combined;
    if (fallback != null && fallback.trim().isNotEmpty) return fallback.trim();
    return 'Unknown';
  }

  /// Two-letter initials for avatars.
  String get initials {
    final first = firstName?.trim();
    final last = lastName?.trim();
    if (first != null && first.isNotEmpty && last != null && last.isNotEmpty) {
      return '${first[0]}${last[0]}'.toUpperCase();
    }
    if (first != null && first.isNotEmpty) return first[0].toUpperCase();
    if (last != null && last.isNotEmpty) return last[0].toUpperCase();
    if (name.isNotEmpty) {
      final parts = name.trim().split(RegExp(r'\s+'));
      if (parts.length >= 2) {
        return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
      }
      return name[0].toUpperCase();
    }
    return '?';
  }

  String? get formattedAddress {
    final parts = <String>[
      if (addressLine1 != null && addressLine1!.isNotEmpty) addressLine1!,
      if (addressLine2 != null && addressLine2!.isNotEmpty) addressLine2!,
      if (city != null && city!.isNotEmpty) city!,
      if (state != null && state!.isNotEmpty) state!,
      if (postalCode != null && postalCode!.isNotEmpty) postalCode!,
      if (country != null && country!.isNotEmpty) country!,
    ];
    if (parts.isEmpty) return null;
    return parts.join(', ');
  }

  /// Days since last call, or null if never called.
  int? get daysSinceLastCall {
    final last = lastCalledAt;
    if (last == null) return null;
    return DateTime.now().difference(last).inDays;
  }

  /// True if never called or past their target call frequency.
  bool get isOverdue {
    final days = daysSinceLastCall;
    if (days == null) return true;
    return days >= targetFrequencyDays;
  }

  Contact copyWith({
    String? id,
    String? userId,
    String? name,
    String? phone,
    String? photoUrl,
    String? notes,
    ContactTag? tag,
    bool clearTag = false,
    int? targetFrequencyDays,
    DateTime? lastCalledAt,
    int? relationshipScore,
    DateTime? createdAt,
    String? firstName,
    String? lastName,
    String? email,
    String? company,
    String? jobTitle,
    DateTime? birthday,
    String? secondaryPhone,
    String? website,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? postalCode,
    String? country,
    String? deviceNativeId,
    bool? syncToDevice,
    DateTime? lastDeviceSyncAt,
  }) {
    return Contact(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      notes: notes ?? this.notes,
      tag: clearTag ? null : (tag ?? this.tag),
      targetFrequencyDays: targetFrequencyDays ?? this.targetFrequencyDays,
      lastCalledAt: lastCalledAt ?? this.lastCalledAt,
      relationshipScore: relationshipScore ?? this.relationshipScore,
      createdAt: createdAt ?? this.createdAt,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      company: company ?? this.company,
      jobTitle: jobTitle ?? this.jobTitle,
      birthday: birthday ?? this.birthday,
      secondaryPhone: secondaryPhone ?? this.secondaryPhone,
      website: website ?? this.website,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      deviceNativeId: deviceNativeId ?? this.deviceNativeId,
      syncToDevice: syncToDevice ?? this.syncToDevice,
      lastDeviceSyncAt: lastDeviceSyncAt ?? this.lastDeviceSyncAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'name': name,
      'phone': phone,
      if (photoUrl != null) 'photo_url': photoUrl,
      if (notes != null) 'notes': notes,
      if (tag != null) 'tag': tag!.value,
      'target_frequency_days': targetFrequencyDays,
      'last_called_at': lastCalledAt?.toIso8601String(),
      'relationship_score': relationshipScore,
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (email != null) 'email': email,
      if (company != null) 'company': company,
      if (jobTitle != null) 'job_title': jobTitle,
      if (birthday != null) 'birthday': _formatBirthday(birthday!),
      if (secondaryPhone != null) 'secondary_phone': secondaryPhone,
      if (website != null) 'website': website,
      if (addressLine1 != null) 'address_line1': addressLine1,
      if (addressLine2 != null) 'address_line2': addressLine2,
      if (city != null) 'city': city,
      if (state != null) 'state': state,
      if (postalCode != null) 'postal_code': postalCode,
      if (country != null) 'country': country,
      if (deviceNativeId != null) 'device_native_id': deviceNativeId,
      'sync_to_device': syncToDevice,
      if (lastDeviceSyncAt != null)
        'last_device_sync_at': lastDeviceSyncAt!.toIso8601String(),
    };
  }

  /// Safe payload for updates — omits immutable ownership fields.
  Map<String, dynamic> toUpdateJson() {
    return {
      'name': name.trim(),
      'phone': phone,
      if (photoUrl != null) 'photo_url': photoUrl,
      if (notes != null) 'notes': notes,
      'tag': tag?.value,
      'target_frequency_days': targetFrequencyDays,
      if (lastCalledAt != null)
        'last_called_at': lastCalledAt!.toIso8601String(),
      'relationship_score': relationshipScore,
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (email != null) 'email': email,
      if (company != null) 'company': company,
      if (jobTitle != null) 'job_title': jobTitle,
      if (birthday != null) 'birthday': _formatBirthday(birthday!),
      if (secondaryPhone != null) 'secondary_phone': secondaryPhone,
      if (website != null) 'website': website,
      if (addressLine1 != null) 'address_line1': addressLine1,
      if (addressLine2 != null) 'address_line2': addressLine2,
      if (city != null) 'city': city,
      if (state != null) 'state': state,
      if (postalCode != null) 'postal_code': postalCode,
      if (country != null) 'country': country,
      if (deviceNativeId != null) 'device_native_id': deviceNativeId,
      'sync_to_device': syncToDevice,
      if (lastDeviceSyncAt != null)
        'last_device_sync_at': lastDeviceSyncAt!.toIso8601String(),
    };
  }

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'] as String?,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      photoUrl: json['photo_url'] as String?,
      notes: json['notes'] as String?,
      tag: ContactTag.fromValue(json['tag'] as String?),
      targetFrequencyDays: json['target_frequency_days'] as int? ?? 30,
      lastCalledAt: json['last_called_at'] != null
          ? DateTime.parse(json['last_called_at'] as String)
          : null,
      relationshipScore: json['relationship_score'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      email: json['email'] as String?,
      company: json['company'] as String?,
      jobTitle: json['job_title'] as String?,
      birthday: _parseBirthday(json['birthday']),
      secondaryPhone: json['secondary_phone'] as String?,
      website: json['website'] as String?,
      addressLine1: json['address_line1'] as String?,
      addressLine2: json['address_line2'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      postalCode: json['postal_code'] as String?,
      country: json['country'] as String?,
      deviceNativeId: json['device_native_id'] as String?,
      syncToDevice: json['sync_to_device'] as bool? ?? true,
      lastDeviceSyncAt: json['last_device_sync_at'] != null
          ? DateTime.parse(json['last_device_sync_at'] as String)
          : null,
    );
  }

  static String _formatBirthday(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  static DateTime? _parseBirthday(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value as String);
  }

  @override
  String toString() => 'Contact(id: $id, name: $name)';
}
