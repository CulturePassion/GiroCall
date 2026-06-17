import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/primary_button.dart';
import '../providers/contacts_notifier.dart';
import '../widgets/contact_form_fields.dart';

class AddContactScreen extends ConsumerStatefulWidget {
  const AddContactScreen({super.key});

  @override
  ConsumerState<AddContactScreen> createState() => _AddContactScreenState();
}

class _AddContactScreenState extends ConsumerState<AddContactScreen> {
  final _formData = ContactFormData();
  bool _saving = false;

  Future<void> _save() async {
    final error = _formData.validate();
    if (error != null) {
      _showError(error);
      return;
    }

    final userId = ref.read(contactsNotifierProvider.notifier).currentUserId;
    if (userId == null) {
      _showError('You must be signed in.');
      return;
    }

    setState(() => _saving = true);
    try {
      await ref
          .read(contactsNotifierProvider.notifier)
          .addContact(_formData.toContact(userId: userId));
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) _showError(e.toString());
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
    return AppScaffold(
      title: 'Add Contact',
      actions: [
        IconButton(
          icon: const Icon(Icons.qr_code_scanner),
          tooltip: 'Scan QR code',
          onPressed: () => context.push('/contacts/scan'),
        ),
      ],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ContactFormFields(
              data: _formData,
              onChanged: () => setState(() {}),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Save contact',
              onPressed:
                  _formData.validate() == null && !_saving ? _save : null,
              isLoading: _saving,
            ),
          ],
        ),
      ),
    );
  }
}
