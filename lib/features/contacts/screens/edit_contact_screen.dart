import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/colors.dart';
import '../../../core/design/microcopy.dart';
import '../../../core/errors/app_messenger.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../core/constants.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../shared/models/contact.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/responsive_page.dart';
import '../../../shared/widgets/primary_button.dart';
import '../providers/contact_by_id_provider.dart';
import '../providers/contacts_notifier.dart';
import '../widgets/contact_form_fields.dart';

class EditContactScreen extends ConsumerStatefulWidget {
  final String contactId;

  const EditContactScreen({super.key, required this.contactId});

  @override
  ConsumerState<EditContactScreen> createState() => _EditContactScreenState();
}

class _EditContactScreenState extends ConsumerState<EditContactScreen> {
  final _formData = ContactFormData();
  bool _initialized = false;
  bool _saving = false;

  void _populate(Contact contact) {
    if (_initialized) return;
    _formData.applyFromContact(contact);
    _initialized = true;
  }

  Future<void> _save(Contact existing) async {
    final error = _formData.validate();
    if (error != null) {
      _showError(error);
      return;
    }

    setState(() => _saving = true);
    try {
      await ref.read(contactsNotifierProvider.notifier).updateContact(
            _formData.toContact(
              userId: existing.userId,
              id: existing.id,
              deviceNativeId: existing.deviceNativeId,
              lastCalledAt: existing.lastCalledAt,
            ),
          );
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) AppMessenger.showError(context, e);
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
    final contactAsync = ref.watch(contactByIdProvider(widget.contactId));

    return contactAsync.when(
      data: (contact) {
        if (contact == null) {
          return const AppScaffold(
            title: 'Edit Contact',
            body: Center(child: Text('Contact not found.')),
          );
        }

        _populate(contact);

        return AppScaffold(
          title: 'Edit Contact',
          responsiveWidth: ResponsivePageWidth.form,
          body: SingleChildScrollView(
            padding:
                EdgeInsets.all(ResponsiveLayout.horizontalPadding(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ContactFormFields(
                  data: _formData,
                  onChanged: () => setState(() {}),
                ),
                const SizedBox(height: 16),
                Text(
                  'Relationship closeness',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(Constants.maxStarRating, (index) {
                    final star = index + 1;
                    return IconButton(
                      onPressed: () {
                        setState(() => _formData.relationshipScore = star);
                      },
                      icon: Icon(
                        (_formData.relationshipScore ?? 0) >= star
                            ? Icons.star
                            : Icons.star_border,
                        color: AppColors.accentCoral,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: 'Save changes',
                  onPressed: _formData.validate() == null && !_saving
                      ? () => _save(contact)
                      : null,
                  isLoading: _saving,
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const AppScaffold(
        title: 'Edit Contact',
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => AppScaffold(
        title: 'Edit Contact',
        body: ErrorState(
          error: error,
          title: Microcopy.errorLoadContacts,
          onRetry: () => ref.invalidate(contactsNotifierProvider),
        ),
      ),
    );
  }
}
