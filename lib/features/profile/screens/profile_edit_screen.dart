import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/colors.dart';
import '../../../core/design/spacing.dart';
import '../../../core/design/tokens.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/utils/screen_padding.dart';
import '../../../core/utils/supabase_error_message.dart';
import '../../../shared/models/user_profile.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/glass_surface.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/profile_avatar_picker.dart';
import '../../../shared/widgets/responsive_page.dart';
import '../providers/avatar_upload_provider.dart';
import '../providers/profile_notifier.dart';
import '../providers/profile_repository_provider.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _displayName = TextEditingController();
  final _slug = TextEditingController();
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
  bool _isPublic = false;
  bool _initialized = false;
  bool _saving = false;
  bool _uploadingAvatar = false;
  String? _avatarUrl;

  @override
  void dispose() {
    _displayName.dispose();
    _slug.dispose();
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
    _slug.text = profile.slug;
    _title.text = profile.title ?? '';
    _company.text = profile.company ?? '';
    _bio.text = profile.bio ?? '';
    _phone.text = profile.phone ?? '';
    _email.text = profile.email ?? '';
    _website.text = profile.website ?? '';
    _address1.text = profile.addressLine1 ?? '';
    _address2.text = profile.addressLine2 ?? '';
    _city.text = profile.city ?? '';
    _state.text = profile.state ?? '';
    _postal.text = profile.postalCode ?? '';
    _country.text = profile.country ?? '';
    _linkedin.text = profile.linkedinUrl ?? '';
    _twitter.text = profile.twitterUrl ?? '';
    _instagram.text = profile.instagramUrl ?? '';
    _facebook.text = profile.facebookUrl ?? '';
    _tiktok.text = profile.tiktokUrl ?? '';
    _youtube.text = profile.youtubeUrl ?? '';
    _isPublic = profile.isPublic;
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
      _showError(supabaseErrorMessage(e));
    } finally {
      if (mounted) setState(() => _uploadingAvatar = false);
    }
  }

  Future<void> _save(UserProfile existing) async {
    setState(() => _saving = true);
    try {
      final repo = ref.read(profileRepositoryProvider);
      final slug = _slug.text.trim().toLowerCase();
      final available = await repo.isSlugAvailable(
        slug,
        excludeUserId: existing.userId,
      );
      if (!available) {
        _showError('That username is already taken.');
        return;
      }

      final updated = existing.copyWith(
        slug: slug,
        displayName: _displayName.text.trim(),
        title: _optional(_title.text),
        company: _optional(_company.text),
        bio: _optional(_bio.text),
        phone: _optional(_phone.text),
        email: _optional(_email.text),
        website: _optional(_website.text),
        addressLine1: _optional(_address1.text),
        addressLine2: _optional(_address2.text),
        city: _optional(_city.text),
        state: _optional(_state.text),
        postalCode: _optional(_postal.text),
        country: _optional(_country.text),
        linkedinUrl: _optional(_linkedin.text),
        twitterUrl: _optional(_twitter.text),
        instagramUrl: _optional(_instagram.text),
        facebookUrl: _optional(_facebook.text),
        tiktokUrl: _optional(_tiktok.text),
        youtubeUrl: _optional(_youtube.text),
        isPublic: _isPublic,
        avatarUrl: _avatarUrl,
      );

      await ref.read(profileNotifierProvider.notifier).saveProfile(updated);
      if (mounted) context.pop();
    } catch (e) {
      _showError(supabaseErrorMessage(e));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileNotifierProvider);
    final hPad = ResponsiveLayout.horizontalPadding(context);

    return profileAsync.when(
      data: (profile) {
        if (profile == null) {
          return const AppScaffold(
            title: 'Edit Card',
            responsiveWidth: ResponsivePageWidth.form,
            body: Center(child: Text('Sign in to edit your card.')),
          );
        }

        _populate(profile);

        return AppScaffold(
          title: 'Edit Card',
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
                GlassSurface(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.sm,
                    horizontal: AppSpacing.xs,
                  ),
                  borderRadius: AppTokens.radiusLg,
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
                _sectionTitle(context, 'Public link'),
                SwitchListTile(
                  value: _isPublic,
                  onChanged: (v) => setState(() => _isPublic = v),
                  title: const Text('Make card public'),
                  subtitle: const Text(
                    'Enables QR code, share link, and wallet pass for networking.',
                  ),
                  activeThumbColor: AppColors.primaryTeal,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _slug,
                  decoration: const InputDecoration(
                    labelText: 'Username (link slug)',
                    prefixText: 'girocall.com/card/',
                    prefixIcon: Icon(Icons.link),
                  ),
                ),
                const SizedBox(height: 24),
                _sectionTitle(context, 'About you'),
                TextField(
                  controller: _displayName,
                  decoration: const InputDecoration(
                    labelText: 'Display name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _title,
                  decoration: const InputDecoration(
                    labelText: 'Title / role',
                    prefixIcon: Icon(Icons.work_outline),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _company,
                  decoration: const InputDecoration(
                    labelText: 'Company',
                    prefixIcon: Icon(Icons.business_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _bio,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Bio',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 24),
                _sectionTitle(context, 'Contact info'),
                TextField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _website,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                    labelText: 'Website',
                    prefixIcon: Icon(Icons.language_outlined),
                  ),
                ),
                const SizedBox(height: 24),
                _sectionTitle(context, 'Address'),
                TextField(
                  controller: _address1,
                  decoration:
                      const InputDecoration(labelText: 'Address line 1'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _address2,
                  decoration:
                      const InputDecoration(labelText: 'Address line 2'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _city,
                        decoration: const InputDecoration(labelText: 'City'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _state,
                        decoration: const InputDecoration(labelText: 'State'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _postal,
                        decoration: const InputDecoration(labelText: 'Postal'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _country,
                        decoration: const InputDecoration(labelText: 'Country'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _sectionTitle(context, 'Social media'),
                _socialField(_linkedin, 'LinkedIn URL', Icons.work_outline),
                _socialField(
                    _twitter, 'X / Twitter URL', Icons.alternate_email),
                _socialField(
                    _instagram, 'Instagram URL', Icons.camera_alt_outlined),
                _socialField(_facebook, 'Facebook URL', Icons.facebook),
                _socialField(_tiktok, 'TikTok URL', Icons.music_note_outlined),
                _socialField(
                    _youtube, 'YouTube URL', Icons.play_circle_outline),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: 'Save card',
                  onPressed: _saving ? null : () => _save(profile),
                  isLoading: _saving,
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const AppScaffold(
        title: 'Edit Card',
        responsiveWidth: ResponsivePageWidth.form,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => AppScaffold(
        title: 'Edit Card',
        responsiveWidth: ResponsivePageWidth.form,
        body: Center(child: Text(supabaseErrorMessage(error))),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }

  Widget _socialField(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.url,
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      ),
    );
  }
}
