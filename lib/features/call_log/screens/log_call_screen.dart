import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/app_colors.dart';
import '../../../shared/models/call_log.dart';
import '../../../shared/models/contact.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/star_rating.dart';
import '../../contacts/providers/contact_by_id_provider.dart';
import '../../contacts/providers/contacts_notifier.dart';
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
    if (contact == null) return;

    final userId = ref.read(contactsNotifierProvider.notifier).currentUserId;
    if (userId == null) {
      _showError('You must be signed in.');
      return;
    }

    final durationText = _durationController.text.trim();
    final minutes = durationText.isEmpty ? null : int.tryParse(durationText);
    final durationSeconds = minutes == null ? null : minutes * 60;

    setState(() => _isSubmitting = true);

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

    setState(() => _isSubmitting = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Great call! How did it feel?')),
      );
      context.go('/');
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
        body: Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildBody(BuildContext context, Contact contact) {
    return AppScaffold(
      title: 'Log Call',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primaryTeal,
              child: Text(
                contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?',
                style: const TextStyle(
                  fontSize: 32,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              contact.name,
              style: Theme.of(context).textTheme.displaySmall,
              textAlign: TextAlign.center,
            ),
            Text(
              contact.phone,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              label: 'Tap to call',
              icon: Icons.phone,
              onPressed: _call,
            ),
            const SizedBox(height: 32),
            Text(
              'How did the call feel?',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Center(
              child: StarRating(
                rating: _rating,
                onChanged: (rating) => setState(() => _rating = rating),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _durationController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Duration in minutes (optional)',
                prefixIcon: Icon(Icons.timer_outlined),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              label: 'Save call',
              onPressed: _logCall,
              isLoading: _isSubmitting,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
