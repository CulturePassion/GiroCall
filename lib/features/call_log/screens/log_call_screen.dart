import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/design/colors.dart';
import '../../../core/design/spacing.dart';
import '../../../core/design/microcopy.dart';
import '../../../core/errors/app_messenger.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../core/design/tokens.dart';
import '../../../core/utils/screen_padding.dart';

import '../../../shared/models/call_log.dart';
import '../../../shared/models/contact.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/premium_card.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/star_rating.dart';
import '../../contacts/providers/contact_by_id_provider.dart';
import '../../contacts/providers/contacts_notifier.dart';
import '../../status/widgets/status_avatar.dart';
import '../providers/call_log_notifier.dart';

class LogCallScreen extends ConsumerStatefulWidget {
  final String contactId;

  const LogCallScreen({
    super.key,
    required this.contactId,
  });

  @override
  ConsumerState<LogCallScreen> createState() => _LogCallScreenState();
}

class _LogCallScreenState extends ConsumerState<LogCallScreen> {
  int _rating = 3;
  final _notesController = TextEditingController();
  final _durationController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _notesController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _call() async {
    final contact = _currentContact;
    if (contact == null) return;

    final uri = Uri(scheme: 'tel', path: contact.phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the dialer.')),
        );
      }
    }
  }

  Future<void> _logCall() async {
    final contact = _currentContact;
    if (contact == null) {
      _showError('Contact not found.');
      return;
    }

    final userId = ref.read(contactsNotifierProvider.notifier).currentUserId;
    if (userId == null) {
      _showError('You must be signed in.');
      return;
    }

    final durationText = _durationController.text.trim();
    final minutes = durationText.isEmpty ? null : int.tryParse(durationText);
    final durationSeconds = minutes == null ? null : minutes * 60;

    setState(() => _isSubmitting = true);

    try {
      await ref.read(callLogNotifierProvider.notifier).addLog(CallLog(
            userId: userId,
            contactId: widget.contactId,
            calledAt: DateTime.now(),
            durationSeconds: durationSeconds,
            callRating: _rating,
            notes: _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
          ));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(Microcopy.callSaved)),
        );
        context.go('/');
      }
    } catch (e) {
      if (mounted) AppMessenger.showError(context, e);
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Contact? get _currentContact {
    return ref.read(contactByIdProvider(widget.contactId)).value;
  }

  @override
  Widget build(BuildContext context) {
    final contactAsync = ref.watch(contactByIdProvider(widget.contactId));

    return contactAsync.when(
      data: (contact) {
        if (contact == null) {
          return const AppScaffold(
            title: 'Log Call',
            body: Center(child: Text('Contact not found.')),
          );
        }
        return _buildBody(context, contact);
      },
      loading: () => const AppScaffold(
        title: 'Log Call',
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => AppScaffold(
        title: 'Log Call',
        body: ErrorState(
          error: error,
          title: Microcopy.errorLoadContacts,
          onRetry: () => ref.invalidate(contactsNotifierProvider),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, Contact contact) {
    return AppScaffold(
      title: 'Log Call',
      body: SingleChildScrollView(
        padding: ScreenPadding.all(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PremiumCard(
              accentColor: AppColors.vibrantGreen,
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  StatusAvatar(
                    initials: contact.initials,
                    imageUrl: contact.photoUrl,
                    radius: 40,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    contact.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    contact.phone,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  PrimaryButton(
                    label: Microcopy.callTapToCall,
                    icon: Icons.phone,
                    backgroundColor: AppColors.vibrantGreen,
                    onPressed: _call,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            PremiumCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    Microcopy.callFeelPrompt,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Center(
                    child: StarRating(
                      rating: _rating,
                      onChanged: (rating) => setState(() => _rating = rating),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: _durationController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Duration in minutes (optional)',
                      prefixIcon: Icon(Icons.timer_outlined),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Notes (optional)',
                      hintText: 'A sweet moment to remember…',
                      alignLabelWithHint: true,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            PrimaryButton(
              label: 'Save call',
              onPressed: _logCall,
              isLoading: _isSubmitting,
            ),
            const SizedBox(height: AppSpacing.xs),
            TextButton(
              style: TextButton.styleFrom(
                minimumSize: const Size(0, AppTokens.minTouchTarget),
              ),
              onPressed: () => context.pop(),
              child: const Text('Not now'),
            ),
          ],
        ),
      ),
    );
  }
}
