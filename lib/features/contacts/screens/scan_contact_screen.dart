import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/design/colors.dart';
import '../../../core/design/tokens.dart';
import '../../../core/errors/app_messenger.dart';
import '../../../core/supabase_provider.dart';
import '../../../core/utils/card_url.dart';
import '../../../core/utils/vcard_parser.dart';
import '../../../features/profile/providers/profile_notifier.dart';
import '../../../features/profile/services/contact_save_service.dart';
import '../../../features/profile/services/wallet_service.dart';
import '../../../features/profile/widgets/digital_card_view.dart';
import '../../../shared/models/user_profile.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/primary_button.dart';
import '../providers/contacts_notifier.dart';
import '../widgets/contact_form_fields.dart';

class ScanContactScreen extends ConsumerStatefulWidget {
  const ScanContactScreen({super.key});

  @override
  ConsumerState<ScanContactScreen> createState() => _ScanContactScreenState();
}

class _ScanContactScreenState extends ConsumerState<ScanContactScreen> {
  final _formData = ContactFormData();
  final _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  bool _scanned = false;
  bool _saving = false;
  String? _scanHint;
  String? _scannedProfileSlug; // For GiroCall business cards
  String? _scannedProfileUrl;
  bool _isFlashOn = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _handleBarcode(BarcodeCapture capture) {
    if (_scanned) return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null || raw.isEmpty) return;

    final userId = ref.read(contactsNotifierProvider.notifier).currentUserId;
    if (userId == null) return;

    // Check for GiroCall profile / business card link first
    final slug = _extractGiroCallSlug(raw);
    if (slug != null) {
      final url = raw.contains('://') ? raw : 'https://$raw';
      setState(() {
        _scanned = true;
        _scannedProfileSlug = slug;
        _scannedProfileUrl = url;
        _scanHint = 'GiroCall Business Card scanned.';
      });
      _scannerController.stop();
      return;
    }

    final ContactDraft? draft = VCardParser.parse(raw, userId: userId);

    if (draft == null && (raw.contains('/card/') || raw.contains('/me/'))) {
      // Fallback detection
      setState(() {
        _scanned = true;
        _scanHint =
            'This is a GiroCall digital card link. Open it in a browser to save, '
            'or scan a contact QR / vCard instead.';
      });
      return;
    }

    if (draft == null) {
      setState(() {
        _scanned = true;
        _scanHint = 'Could not read contact from this QR code.';
      });
      return;
    }

    setState(() {
      _scanned = true;
      _formData.applyFromDraft(
        firstName: draft.firstName,
        lastName: draft.lastName,
        phone: draft.phone,
        secondaryPhone: draft.secondaryPhone,
        email: draft.email,
        company: draft.company,
        jobTitle: draft.jobTitle,
        website: draft.website,
        notes: draft.notes,
        addressLine1: draft.addressLine1,
        city: draft.city,
        state: draft.state,
        postalCode: draft.postalCode,
        country: draft.country,
        birthday: draft.birthday,
      );
      _scanHint = 'Contact scanned — review and save.';
    });
    _scannerController.stop();
  }

  String? _extractGiroCallSlug(String raw) {
    final lower = raw.toLowerCase();
    if (!lower.contains('/me/') && !lower.contains('/card/')) return null;

    // Try as URI
    Uri? uri;
    try {
      uri = Uri.parse(raw.contains('://') ? raw : 'https://$raw');
    } catch (_) {}

    if (uri != null) {
      for (final seg in uri.pathSegments.reversed) {
        if (seg.isNotEmpty && seg != 'me' && seg != 'card' && seg.length > 1) {
          return seg;
        }
      }
    }

    // Regex fallback
    final match =
        RegExp(r'/me/([a-z0-9_-]+)|/card/([a-z0-9_-]+)').firstMatch(lower);
    if (match != null) {
      return match.group(1) ?? match.group(2);
    }
    return null;
  }

  Future<void> _save() async {
    final error = _formData.validate();
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    final userId = ref.read(contactsNotifierProvider.notifier).currentUserId;
    if (userId == null) return;

    setState(() => _saving = true);
    try {
      await ref
          .read(contactsNotifierProvider.notifier)
          .addContact(_formData.toContact(userId: userId));
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        AppMessenger.showError(context, e);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _buildBusinessCardPreview(BuildContext context) {
    final slug = _scannedProfileSlug!;
    final url = _scannedProfileUrl ?? CardUrl.publicCardUrl(slug);

    final supabaseUrl = ref.read(supabaseConfigProvider).url;
    final walletService = WalletService(supabaseUrl: supabaseUrl);
    final saveService = ref.read(contactSaveServiceProvider);

    final profileAsync = ref.watch(publicProfileProvider(slug));

    return AppScaffold(
      title: 'Business Card Scanned',
      body: profileAsync.when(
        data: (profile) {
          if (profile == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.qr_code_2,
                        size: 64, color: AppColors.vibrantGreen),
                    const SizedBox(height: 16),
                    Text('Business Card for @$slug'),
                    const SizedBox(height: 8),
                    Text(
                      url,
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    _buildSimpleCardPreview(url),
                    const SizedBox(height: 24),
                    _buildCardActions(slug, url, saveService, walletService),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: _rescan,
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text('Scan again'),
                    ),
                  ],
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                DigitalCardView(
                  profile: profile,
                  variant: DigitalCardVariant.public,
                  showQr: true,
                  onSaveContact: () async {
                    await saveService.saveProfileContact(profile);
                    if (!mounted) return;
                    final ctx = context;
                    AppMessenger.showInfo(ctx, 'Saved to contacts');
                    if (mounted) ctx.pop();
                  },
                  onAppleWallet: walletService.isMobile
                      ? () => walletService.addToAppleWallet(slug)
                      : null,
                  onGoogleWallet: walletService.isMobile
                      ? () => walletService.addToGoogleWallet(slug)
                      : null,
                ),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: _rescan,
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('Scan another'),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Could not load full card: $e'),
                const SizedBox(height: 16),
                _buildSimpleCardPreview(url),
                const SizedBox(height: 16),
                _buildCardActions(slug, url, saveService, walletService),
                const SizedBox(height: 16),
                OutlinedButton(
                    onPressed: _rescan, child: const Text('Scan again')),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleCardPreview(String url) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardSurface(context),
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        children: [
          Text(
            'GiroCall Business Card',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 180,
            height: 180,
            child: QrImageView(
              data: url,
              version: QrVersions.auto,
              eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square, color: AppColors.vibrantGreen),
              dataModuleStyle:
                  const QrDataModuleStyle(color: AppColors.textPrimary),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            url,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCardActions(
    String slug,
    String url,
    ContactSaveService saveService,
    WalletService walletService,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PrimaryButton(
          label: 'Save to contacts (.vcf)',
          onPressed: () async {
            // For full data prefer the loaded profile path; here use link-based
            await saveService.saveProfileContact(
              UserProfile(
                userId: 'scan-$slug',
                slug: slug,
                displayName: 'GiroCall Contact',
                isPublic: true,
              ),
            );
            if (!mounted) return;
            context.pop();
          },
        ),
        const SizedBox(height: 8),
        if (walletService.isMobile) ...[
          OutlinedButton.icon(
            onPressed: () => walletService.addToAppleWallet(slug),
            icon: const Icon(Icons.phone_iphone),
            label: const Text('Add to Apple Wallet'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => walletService.addToGoogleWallet(slug),
            icon: const Icon(Icons.android),
            label: const Text('Add to Google Wallet'),
          ),
        ],
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () => context.push('/me/$slug'),
          child: const Text('View full card'),
        ),
      ],
    );
  }

  void _rescan() {
    setState(() {
      _scanned = false;
      _scanHint = null;
      _scannedProfileSlug = null;
      _scannedProfileUrl = null;
      _isFlashOn = false;
    });
    _scannerController.start();
  }

  Future<void> _toggleFlash() async {
    try {
      await _scannerController.toggleTorch();
      setState(() => _isFlashOn = !_isFlashOn);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_scanned) {
      if (_scannedProfileSlug != null) {
        return _buildBusinessCardPreview(context);
      }

      return AppScaffold(
        title: 'Review contact',
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_scanHint != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _scanHint!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ),
              ContactFormFields(
                data: _formData,
                onChanged: () => setState(() {}),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Save contact',
                onPressed: _formData.validate() == null ? _save : null,
                isLoading: _saving,
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _rescan,
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Scan again'),
              ),
            ],
          ),
        ),
      );
    }

    if (kIsWeb) {
      return AppScaffold(
        title: 'Scan to Connect',
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.qr_code_scanner,
                    size: 64, color: AppColors.vibrantGreen),
                const SizedBox(height: 16),
                const Text(
                  'QR scanning works best on iPhone and Android.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () => context.push('/contacts/add'),
                  child: const Text('Add contact manually'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return AppScaffold(
      title: 'Scan to Connect',
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: _handleBarcode,
          ),
          // Scanner overlay with modern frame hint
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: 0,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                margin: const EdgeInsets.all(40),
              ),
            ),
          ),
          // Flash toggle for better scanning
          Positioned(
            top: 16,
            right: 16,
            child: IconButton(
              onPressed: _toggleFlash,
              icon: Icon(
                _isFlashOn ? Icons.flash_on : Icons.flash_off,
                color: Colors.white,
              ),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black.withValues(alpha: 0.5),
              ),
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 40,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(AppTokens.radiusMd),
              ),
              child: const Text(
                'Scan a contact vCard QR\n'
                'or GiroCall Business Card to connect',
                textAlign: TextAlign.center,
                style:
                    TextStyle(color: Colors.white, height: 1.3, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
