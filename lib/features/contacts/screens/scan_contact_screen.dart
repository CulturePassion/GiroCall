import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/design/colors.dart';
import '../../../core/utils/vcard_parser.dart';
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

    final ContactDraft? draft = VCardParser.parse(raw, userId: userId);

    if (draft == null && (raw.contains('/card/') || raw.contains('/me/'))) {
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _rescan() {
    setState(() {
      _scanned = false;
      _scanHint = null;
    });
    _scannerController.start();
  }

  @override
  Widget build(BuildContext context) {
    if (_scanned) {
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
        title: 'Scan QR code',
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.qr_code_scanner,
                    size: 64, color: AppColors.primaryTeal),
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
      title: 'Scan QR code',
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: _handleBarcode,
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 32,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'Point at a contact QR code or vCard.\n'
                'GiroCall digital cards also work.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, height: 1.4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
