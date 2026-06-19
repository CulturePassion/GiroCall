import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/spacing.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/utils/screen_padding.dart';
import '../../../core/utils/social_url_utils.dart';
import '../../../core/design/microcopy.dart';
import '../../../core/errors/app_messenger.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/models/user_profile.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/page_header.dart';
import '../../../shared/widgets/premium_card.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/profile_avatar_picker.dart';
import '../../../shared/widgets/responsive_page.dart';
import '../providers/avatar_upload_provider.dart';
import '../providers/profile_notifier.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _displayName = TextEditingController();
  final _title = TextEditingController();
  final _company = TextEditingController();
  final _bio = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _website = TextEditingController();
  final _address1 = TextEditingController();
  final _address2 = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
  final _postal = TextEditingController();
  final _country = TextEditingController();
  final _linkedin = TextEditingController();
  final _twitter = TextEditingController();
  final _instagram = TextEditingController();
  final _facebook = TextEditingController();
  final _tiktok = TextEditingController();
  final _youtube = TextEditingController();
  bool _initialized = false;
  bool _saving = false;
  bool _uploadingAvatar = false;
  String? _avatarUrl;

  @override
  void dispose() {
    _displayName.dispose();
    _title.dispose();
    _company.dispose();
    _bio.dispose();
    _phone.dispose();
    _email.dispose();
    _website.dispose();
    _address1.dispose();
    _address2.dispose();
    _city.dispose();
    _state.dispose();
    _postal.dispose();
    _country.dispose();
    _linkedin.dispose();
    _twitter.dispose();
    _instagram.dispose();
    _facebook.dispose();
    _tiktok.dispose();
    _youtube.dispose();
    super.dispose();
  }

  void _populate(UserProfile profile) {
    if (_initialized) return;
    _displayName.text = profile.displayName;
    _title.text = profile.title ?? '';
    _company.text = profile.company ?? '';
    _bio.text = profile.bio ?? '';
    _phone.text = profile.phone ?? '';
    _email.text = profile.email ?? '';
    _website.text = websiteForField(profile.website);
    _address1.text = profile.addressLine1 ?? '';
    _address2.text = profile.addressLine2 ?? '';
    _city.text = profile.city ?? '';
    _state.text = profile.state ?? '';
    _postal.text = profile.postalCode ?? '';
    _country.text = profile.country ?? '';
    _linkedin.text =
        socialHandleForField(profile.linkedinUrl, SocialUrlPrefixes.linkedin);
    _twitter.text =
        socialHandleForField(profile.twitterUrl, SocialUrlPrefixes.twitter);
    _instagram.text = socialHandleForField(
      profile.instagramUrl,
      SocialUrlPrefixes.instagram,
    );
    _facebook.text =
        socialHandleForField(profile.facebookUrl, SocialUrlPrefixes.facebook);
    _tiktok.text =
        socialHandleForField(profile.tiktokUrl, SocialUrlPrefixes.tiktok);
    _youtube.text =
        socialHandleForField(profile.youtubeUrl, SocialUrlPrefixes.youtube);
    _avatarUrl = profile.avatarUrl;
    _initialized = true;
  }

  String? _optional(String value) => value.trim().isEmpty ? null : value.trim();

  Future<void> _uploadAvatar(
    UserProfile profile, {
    required Uint8List bytes,
    required String mimeType,
  }) async {
    setState(() => _uploadingAvatar = true);
    try {
      final service = ref.read(avatarUploadServiceProvider);
      final url = await service.uploadAvatar(
        bytes: bytes,
        mimeType: mimeType,
      );
      final updated = profile.copyWith(avatarUrl: url);
      await ref.read(profileNotifierProvider.notifier).saveProfile(updated);
      if (mounted) {
        setState(() => _avatarUrl = url);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile photo updated.')),
        );
      }
    } catch (e) {
      if (mounted) AppMessenger.showError(context, e);
    } finally {
      if (mounted) setState(() => _uploadingAvatar = false);
    }
  }

  Future<void> _save(UserProfile existing) async {
    setState(() => _saving = true);
    try {
      final updated = existing.copyWith(
        displayName: _displayName.text.trim(),
        title: _optional(_title.text),
        company: _optional(_company.text),
        bio: _optional(_bio.text),
        phone: _optional(_phone.text),
        email: _optional(_email.text),
        website: normalizeWebsiteUrl(_website.text),
        addressLine1: _optional(_address1.text),
        addressLine2: _optional(_address2.text),
        city: _optional(_city.text),
        state: _optional(_state.text),
        postalCode: _optional(_postal.text),
        country: _optional(_country.text),
        linkedinUrl:
            normalizePrefixedUrl(_linkedin.text, SocialUrlPrefixes.linkedin),
        twitterUrl:
            normalizePrefixedUrl(_twitter.text, SocialUrlPrefixes.twitter),
        instagramUrl: normalizePrefixedUrl(
          _instagram.text,
          SocialUrlPrefixes.instagram,
        ),
        facebookUrl:
            normalizePrefixedUrl(_facebook.text, SocialUrlPrefixes.facebook),
        tiktokUrl: normalizePrefixedUrl(_tiktok.text, SocialUrlPrefixes.tiktok),
        youtubeUrl:
            normalizePrefixedUrl(_youtube.text, SocialUrlPrefixes.youtube),
        avatarUrl: _avatarUrl,
      );

      await ref.read(profileNotifierProvider.notifier).saveProfile(updated);
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) AppMessenger.showError(context, e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileNotifierProvider);
    final hPad = ResponsiveLayout.horizontalPadding(context);

    return profileAsync.when(
      data: (profile) {
        if (profile == null) {
          return const AppScaffold(
            title: 'Edit Profile',
            responsiveWidth: ResponsivePageWidth.form,
            body: Center(child: Text('Sign in to edit your profile.')),
          );
        }

        _populate(profile);

        return AppScaffold(
          title: 'Edit Profile',
          responsiveWidth: ResponsivePageWidth.form,
          body: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              hPad,
              AppSpacing.xs,
              hPad,
              ScreenPadding.bottomNavClearance(context),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const PageHeader(
                  title: 'Your details',
                  subtitle:
                      'Handles only — no full links needed. We build the URLs for you.',
                ),
                PremiumCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Center(
                    child: ProfileAvatarPicker(
                      imageUrl: _avatarUrl,
                      initials: _displayName.text.isNotEmpty
                          ? _displayName.text
                          : profile.displayName,
                      uploading: _uploadingAvatar,
                      onImagePicked: (picked) => _uploadAvatar(
                        profile,
                        bytes: picked.bytes,
                        mimeType: picked.mimeType,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                PremiumCard(
                  child: Material(
                    color: Colors.transparent,
                    child: ListTile(
                      leading: const Icon(Icons.badge_outlined),
                      title: const Text('Public username'),
                      subtitle: Text(profile.slug),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/profile/card'),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                _sectionCard(
                  context,
                  title: 'About you',
                  children: [
                    _field(
                      controller: _displayName,
                      label: 'Display name',
                      icon: Icons.person_outline,
                    ),
                    _field(
                      controller: _title,
                      label: 'Title / role',
                      icon: Icons.work_outline,
                    ),
                    _field(
                      controller: _company,
                      label: 'Company',
                      icon: Icons.business_outlined,
                    ),
                    _field(
                      controller: _bio,
                      label: 'Bio',
                      maxLines: 3,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                _sectionCard(
                  context,
                  title: 'Contact info',
                  children: [
                    _field(
                      controller: _phone,
                      label: 'Phone',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    _field(
                      controller: _email,
                      label: 'Email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    _field(
                      controller: _website,
                      label: 'Website',
                      icon: Icons.language_outlined,
                      hint: 'yoursite.com',
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                _sectionCard(
                  context,
                  title: 'Address',
                  children: [
                    _field(controller: _address1, label: 'Address line 1'),
                    _field(controller: _address2, label: 'Address line 2'),
                    Row(
                      children: [
                        Expanded(
                          child: _field(controller: _city, label: 'City'),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: _field(controller: _state, label: 'State'),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _field(controller: _postal, label: 'Postal'),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: _field(controller: _country, label: 'Country'),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                _sectionCard(
                  context,
                  title: 'Social media',
                  children: [
                    _socialField(_linkedin, 'LinkedIn', Icons.work_outline,
                        hint: 'your-name'),
                    _socialField(_twitter, 'X / Twitter', Icons.alternate_email,
                        hint: 'handle'),
                    _socialField(
                        _instagram, 'Instagram', Icons.camera_alt_outlined,
                        hint: 'handle'),
                    _socialField(_facebook, 'Facebook', Icons.facebook,
                        hint: 'page or profile'),
                    _socialField(_tiktok, 'TikTok', Icons.music_note_outlined,
                        hint: 'handle'),
                    _socialField(_youtube, 'YouTube', Icons.play_circle_outline,
                        hint: 'channel'),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                PrimaryButton(
                  label: 'Save profile',
                  onPressed: _saving ? null : () => _save(profile),
                  isLoading: _saving,
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const AppScaffold(
        title: 'Edit Profile',
        responsiveWidth: ResponsivePageWidth.form,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => AppScaffold(
        title: 'Edit Profile',
        responsiveWidth: ResponsivePageWidth.form,
        body: ErrorState(
          error: error,
          title: Microcopy.errorLoadProfile,
          onRetry: () =>
              ref.read(profileNotifierProvider.notifier).loadProfile(),
        ),
      ),
    );
  }

  Widget _sectionCard(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return PremiumCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...children,
        ],
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: icon != null ? Icon(icon) : null,
          alignLabelWithHint: maxLines > 1,
        ),
      ),
    );
  }

  Widget _socialField(
    TextEditingController controller,
    String label,
    IconData icon, {
    String? hint,
  }) {
    return _field(
      controller: controller,
      label: label,
      icon: icon,
      hint: hint,
    );
  }
}
