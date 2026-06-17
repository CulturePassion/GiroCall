import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_colors.dart';
import '../../../core/app_spacing.dart';
import '../../../core/constants.dart';
import '../../../core/supabase_provider.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../shared/widgets/glass_surface.dart';
import '../../../shared/widgets/gradient_background.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/responsive_page.dart';
import '../providers/auth_provider.dart';
import '../utils/auth_error_message.dart';

enum _AuthMode { signIn, signUp, resetPassword }

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  _AuthMode _mode = _AuthMode.signIn;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _busy = false;
  String? _resetSentMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;

    setState(() {
      _busy = true;
      _resetSentMessage = null;
    });

    try {
      final notifier = ref.read(authNotifierProvider.notifier);
      if (_mode == _AuthMode.resetPassword) {
        await notifier.resetPasswordForEmail(email);
        if (mounted) {
          setState(() {
            _resetSentMessage =
                'Check your email for a password reset link.';
          });
        }
        return;
      }

      final password = _passwordController.text.trim();
      if (password.isEmpty) return;

      if (_mode == _AuthMode.signUp) {
        if (password.length < 8) {
          _showError('Password must be at least 8 characters.');
          return;
        }
        if (password != _confirmPasswordController.text.trim()) {
          _showError('Passwords do not match.');
          return;
        }
        await notifier.signUpWithEmail(email, password);
      } else {
        await notifier.signInWithEmail(email, password);
      }
    } catch (e) {
      final config = ref.read(supabaseConfigProvider);
      _showError(authErrorMessage(e, supabaseConfigured: config.isConfigured));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final supabaseConfig = ref.watch(supabaseConfigProvider);
    final theme = Theme.of(context);
    final isLoading = _busy || authState.isLoading;
    final isReset = _mode == _AuthMode.resetPassword;
    final isSignUp = _mode == _AuthMode.signUp;

    ref.listen(authNotifierProvider, (previous, next) {
      next.whenOrNull(
        error: (error, _) {
          if (_mode == _AuthMode.resetPassword) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                authErrorMessage(
                  error,
                  supabaseConfigured: supabaseConfig.isConfigured,
                ),
              ),
              duration: const Duration(seconds: 6),
            ),
          );
        },
      );
    });

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: ResponsivePage(
            width: ResponsivePageWidth.form,
            scrollable: true,
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveLayout.horizontalPadding(context),
              vertical: AppSpacing.sm,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: math.max(
                  0,
                  MediaQuery.sizeOf(context).height -
                      MediaQuery.paddingOf(context).vertical -
                      AppSpacing.lg,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!supabaseConfig.isConfigured) ...[
                    GlassSurface(
                      tint: AppColors.orange.withValues(alpha: 0.12),
                      child: const Text(
                        'Supabase is not configured. Copy .env.example to .env, '
                        'add your credentials, then run: make run',
                        style: TextStyle(fontSize: 13, height: 1.5),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  _BrandHeader(theme: theme),
                  const SizedBox(height: AppSpacing.lg),
                  GlassSurface(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    borderRadius: AppSpacing.radiusLg,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SegmentedButton<_AuthMode>(
                          segments: const [
                            ButtonSegment(
                              value: _AuthMode.signIn,
                              label: Text('Sign in'),
                              icon: Icon(Icons.login, size: 18),
                            ),
                            ButtonSegment(
                              value: _AuthMode.signUp,
                              label: Text('Sign up'),
                              icon: Icon(Icons.person_add_outlined, size: 18),
                            ),
                            ButtonSegment(
                              value: _AuthMode.resetPassword,
                              label: Text('Reset'),
                              icon: Icon(Icons.lock_reset, size: 18),
                            ),
                          ],
                          selected: {_mode},
                          onSelectionChanged: (selection) {
                            setState(() {
                              _mode = selection.first;
                              _resetSentMessage = null;
                            });
                          },
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          isReset
                              ? 'Reset your password'
                              : isSignUp
                                  ? 'Create your account'
                                  : 'Welcome back',
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          isReset
                              ? 'We\'ll email you a secure link to choose a new password.'
                              : 'Spin the Giro. Make the call. Stay connected.',
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: isReset
                              ? TextInputAction.done
                              : TextInputAction.next,
                          autofillHints: const [AutofillHints.email],
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          onSubmitted: isReset ? (_) => _submit() : null,
                        ),
                        if (!isReset) ...[
                          const SizedBox(height: AppSpacing.xs),
                          TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            textInputAction: isSignUp
                                ? TextInputAction.next
                                : TextInputAction.done,
                            autofillHints: isSignUp
                                ? const [AutofillHints.newPassword]
                                : const [AutofillHints.password],
                            onSubmitted: (_) => _submit(),
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                                onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                              ),
                            ),
                          ),
                        ],
                        if (isSignUp) ...[
                          const SizedBox(height: AppSpacing.xs),
                          TextField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirm,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [AutofillHints.newPassword],
                            onSubmitted: (_) => _submit(),
                            decoration: InputDecoration(
                              labelText: 'Confirm password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirm
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                                onPressed: () => setState(
                                  () => _obscureConfirm = !_obscureConfirm,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            'At least 8 characters',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                        if (_resetSentMessage != null) ...[
                          const SizedBox(height: AppSpacing.xs),
                          GlassSurface(
                            tint: AppColors.main.withValues(alpha: 0.1),
                            padding: const EdgeInsets.all(AppSpacing.xs),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.mark_email_read_outlined,
                                  color: AppColors.main,
                                ),
                                const SizedBox(width: AppSpacing.xxs),
                                Expanded(
                                  child: Text(
                                    _resetSentMessage!,
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.sm),
                        PrimaryButton(
                          label: isReset
                              ? 'Send reset link'
                              : isSignUp
                                  ? 'Create account'
                                  : 'Sign in',
                          onPressed: isLoading ? null : _submit,
                          isLoading: isLoading,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  final ThemeData theme;

  const _BrandHeader({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Hero(
            tag: 'girocall-logo',
            child: Container(
              height: 96,
              width: 96,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.main, AppColors.blue, AppColors.orange],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.main.withValues(alpha: 0.35),
                    blurRadius: 28,
                    offset: const Offset(0, 12),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.5),
                  width: 3,
                ),
              ),
              child: const Icon(
                Icons.phone_forwarded,
                size: 44,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          Constants.appName,
          style: theme.textTheme.displayMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          Constants.tagline,
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}