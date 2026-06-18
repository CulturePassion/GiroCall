import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/spacing.dart';
import '../../../core/design/tokens.dart';
import '../../../core/supabase_provider.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/glass_surface.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/responsive_page.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/utils/auth_error_message.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _saving = false;

  @override
  void dispose() {
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final password = _newPassword.text.trim();
    final confirm = _confirmPassword.text.trim();

    if (password.length < 8) {
      _showSnack('Password must be at least 8 characters.');
      return;
    }
    if (password != confirm) {
      _showSnack('Passwords do not match.');
      return;
    }

    setState(() => _saving = true);
    try {
      await ref.read(authNotifierProvider.notifier).updatePassword(password);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password updated successfully.')),
        );
        context.pop();
      }
    } catch (e) {
      final config = ref.read(supabaseConfigProvider);
      _showSnack(authErrorMessage(e, supabaseConfigured: config.isConfigured));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Change password',
      responsiveWidth: null,
      body: ResponsivePage(
        width: ResponsivePageWidth.form,
        scrollable: true,
        child: GlassSurface(
          padding: const EdgeInsets.all(AppSpacing.sm),
          borderRadius: AppTokens.radiusLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Choose a strong password you haven\'t used here before.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _newPassword,
                obscureText: _obscureNew,
                autofillHints: const [AutofillHints.newPassword],
                decoration: InputDecoration(
                  labelText: 'New password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNew
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () =>
                        setState(() => _obscureNew = !_obscureNew),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              TextField(
                controller: _confirmPassword,
                obscureText: _obscureConfirm,
                autofillHints: const [AutofillHints.newPassword],
                onSubmitted: (_) => _save(),
                decoration: InputDecoration(
                  labelText: 'Confirm new password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              PrimaryButton(
                label: 'Update password',
                onPressed: _saving ? null : _save,
                isLoading: _saving,
              ),
            ],
          ),
        ),
      ),
    );
  }
}