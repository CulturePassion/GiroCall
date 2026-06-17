import 'package:flutter/foundation.dart';

/// Public digital business card / link-in-bio profile.
@immutable
class UserProfile {
  final String userId;
  final String slug;
  final String displayName;
  final String? title;
  final String? company;
  final String? bio;
  final String? phone;
  final String? email;
  final String? website;
  final String? addressLine1;
  final String? addressLine2;
  final String? city;
  final String? state;
  final String? postalCode;
  final String? country;
  final String? avatarUrl;
  final String? linkedinUrl;
  final String? twitterUrl;
  final String? instagramUrl;
  final String? facebookUrl;
  final String? tiktokUrl;
  final String? youtubeUrl;
  final bool isPublic;
  final String? presenceType;
  final String? presenceMessage;
  final DateTime? presenceUpdatedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserProfile({
    required this.userId,
    required this.slug,
    required this.displayName,
    this.title,
    this.company,
    this.bio,
    this.phone,
    this.email,
    this.website,
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.state,
    this.postalCode,
    this.country,
    this.avatarUrl,
    this.linkedinUrl,
    this.twitterUrl,
    this.instagramUrl,
    this.facebookUrl,
    this.tiktokUrl,
    this.youtubeUrl,
    this.isPublic = false,
    this.presenceType,
    this.presenceMessage,
    this.presenceUpdatedAt,
    this.createdAt,
    this.updatedAt,
  });

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

  List<({String label, String url, String platform})> get socialLinks {
    final links = <({String label, String url, String platform})>[];
    void add(String? url, String label, String platform) {
      if (url != null && url.trim().isNotEmpty) {
        links.add((label: label, url: url.trim(), platform: platform));
      }
    }

    add(linkedinUrl, 'LinkedIn', 'linkedin');
    add(twitterUrl, 'X / Twitter', 'twitter');
    add(instagramUrl, 'Instagram', 'instagram');
    add(facebookUrl, 'Facebook', 'facebook');
    add(tiktokUrl, 'TikTok', 'tiktok');
    add(youtubeUrl, 'YouTube', 'youtube');
    add(website, 'Website', 'website');
    return links;
  }

  bool get hasContactInfo =>
      (phone != null && phone!.isNotEmpty) ||
      (email != null && email!.isNotEmpty) ||
      formattedAddress != null;

  UserProfile copyWith({
    String? slug,
    String? displayName,
    String? title,
    String? company,
    String? bio,
    String? phone,
    String? email,
    String? website,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? postalCode,
    String? country,
    String? avatarUrl,
    String? linkedinUrl,
    String? twitterUrl,
    String? instagramUrl,
    String? facebookUrl,
    String? tiktokUrl,
    String? youtubeUrl,
    bool? isPublic,
    String? presenceType,
    String? presenceMessage,
    DateTime? presenceUpdatedAt,
  }) {
    return UserProfile(
      userId: userId,
      slug: slug ?? this.slug,
      displayName: displayName ?? this.displayName,
      title: title ?? this.title,
      company: company ?? this.company,
      bio: bio ?? this.bio,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      website: website ?? this.website,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      linkedinUrl: linkedinUrl ?? this.linkedinUrl,
      twitterUrl: twitterUrl ?? this.twitterUrl,
      instagramUrl: instagramUrl ?? this.instagramUrl,
      facebookUrl: facebookUrl ?? this.facebookUrl,
      tiktokUrl: tiktokUrl ?? this.tiktokUrl,
      youtubeUrl: youtubeUrl ?? this.youtubeUrl,
      isPublic: isPublic ?? this.isPublic,
      presenceType: presenceType ?? this.presenceType,
      presenceMessage: presenceMessage ?? this.presenceMessage,
      presenceUpdatedAt: presenceUpdatedAt ?? this.presenceUpdatedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'slug': slug,
      'display_name': displayName,
      if (title != null) 'title': title,
      if (company != null) 'company': company,
      if (bio != null) 'bio': bio,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (website != null) 'website': website,
      if (addressLine1 != null) 'address_line1': addressLine1,
      if (addressLine2 != null) 'address_line2': addressLine2,
      if (city != null) 'city': city,
      if (state != null) 'state': state,
      if (postalCode != null) 'postal_code': postalCode,
      if (country != null) 'country': country,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (linkedinUrl != null) 'linkedin_url': linkedinUrl,
      if (twitterUrl != null) 'twitter_url': twitterUrl,
      if (instagramUrl != null) 'instagram_url': instagramUrl,
      if (facebookUrl != null) 'facebook_url': facebookUrl,
      if (tiktokUrl != null) 'tiktok_url': tiktokUrl,
      if (youtubeUrl != null) 'youtube_url': youtubeUrl,
      'is_public': isPublic,
      if (presenceType != null) 'presence_type': presenceType,
      if (presenceMessage != null) 'presence_message': presenceMessage,
      if (presenceUpdatedAt != null)
        'presence_updated_at': presenceUpdatedAt!.toIso8601String(),
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'slug': slug,
      'display_name': displayName.trim(),
      if (title != null) 'title': title,
      if (company != null) 'company': company,
      if (bio != null) 'bio': bio,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (website != null) 'website': website,
      if (addressLine1 != null) 'address_line1': addressLine1,
      if (addressLine2 != null) 'address_line2': addressLine2,
      if (city != null) 'city': city,
      if (state != null) 'state': state,
      if (postalCode != null) 'postal_code': postalCode,
      if (country != null) 'country': country,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (linkedinUrl != null) 'linkedin_url': linkedinUrl,
      if (twitterUrl != null) 'twitter_url': twitterUrl,
      if (instagramUrl != null) 'instagram_url': instagramUrl,
      if (facebookUrl != null) 'facebook_url': facebookUrl,
      if (tiktokUrl != null) 'tiktok_url': tiktokUrl,
      if (youtubeUrl != null) 'youtube_url': youtubeUrl,
      'is_public': isPublic,
      if (presenceType != null) 'presence_type': presenceType,
      if (presenceMessage != null) 'presence_message': presenceMessage,
      if (presenceUpdatedAt != null)
        'presence_updated_at': presenceUpdatedAt!.toIso8601String(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['user_id'] as String,
      slug: json['slug'] as String,
      displayName: json['display_name'] as String? ?? '',
      title: json['title'] as String?,
      company: json['company'] as String?,
      bio: json['bio'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      website: json['website'] as String?,
      addressLine1: json['address_line1'] as String?,
      addressLine2: json['address_line2'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      postalCode: json['postal_code'] as String?,
      country: json['country'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      linkedinUrl: json['linkedin_url'] as String?,
      twitterUrl: json['twitter_url'] as String?,
      instagramUrl: json['instagram_url'] as String?,
      facebookUrl: json['facebook_url'] as String?,
      tiktokUrl: json['tiktok_url'] as String?,
      youtubeUrl: json['youtube_url'] as String?,
      isPublic: json['is_public'] as bool? ?? false,
      presenceType: json['presence_type'] as String?,
      presenceMessage: json['presence_message'] as String?,
      presenceUpdatedAt: json['presence_updated_at'] != null
          ? DateTime.parse(json['presence_updated_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }
}
