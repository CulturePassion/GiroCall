import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants.dart';
import '../../../core/design/colors.dart';
import '../../../core/design/microcopy.dart';
import '../../../core/design/spacing.dart';
import '../../../core/design/tokens.dart';
import '../../../core/errors/app_error_extensions.dart';
import '../../../core/errors/app_messenger.dart';
import '../../../core/supabase_provider.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../shared/widgets/auth_card.dart';
import '../../../shared/widgets/gradient_background.dart';
import '../../../shared/widgets/primary_button.dart';

import '../providers/auth_provider.dart';

enum _AuthMode { signIn, signUp, resetPassword }

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();
  _AuthMode _mode = _AuthMode.signIn;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _busy = false;
  String? _resetSentMessage;
  String? _signUpSentMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();

    setState(() {
      _busy = true;
      _resetSentMessage = null;
      _signUpSentMessage = null;
    });

    try {
      final notifier = ref.read(authNotifierProvider.notifier);
      if (_mode == _AuthMode.resetPassword) {
        await notifier.resetPasswordForEmail(email);
        if (mounted) {
          setState(() {
            _resetSentMessage = 'Check your email for a password reset link.';
          });
        }
        return;
      }

      final password = _passwordController.text.trim();

      if (_mode == _AuthMode.signUp) {
        final result = await notifier.signUpWithEmail(email, password);
        if (!mounted || result == null) return;
        if (result.needsEmailConfirmation) {
          setState(() {
            _signUpSentMessage = Microcopy.authSignUpConfirm;
            _mode = _AuthMode.signIn;
          });
        }
      } else {
        await notifier.signInWithEmail(email, password);
      }
    } catch (e) {
      if (mounted) {
        final config = ref.read(supabaseConfigProvider);
        AppMessenger.showAppError(
          context,
          e.toAppError(supabaseConfigured: config.isConfigured),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _switchMode(_AuthMode mode) {
    setState(() {
      _mode = mode;
      _resetSentMessage = null;
      _signUpSentMessage = null;
    });
  }

  Widget _buildAuthForm({
    required TextStyle fieldStyle,
    required bool isLoading,
    required bool isReset,
    required bool isSignUp,
  }) {
    return _AuthForm(
      mode: _mode,
      formKey: _formKey,
      fieldStyle: fieldStyle,
      isLoading: isLoading,
      isReset: isReset,
      isSignUp: isSignUp,
      resetSentMessage: _resetSentMessage,
      signUpSentMessage: _signUpSentMessage,
      obscurePassword: _obscurePassword,
      obscureConfirm: _obscureConfirm,
      emailController: _emailController,
      passwordController: _passwordController,
      confirmPasswordController: _confirmPasswordController,
      emailFocus: _emailFocus,
      passwordFocus: _passwordFocus,
      confirmFocus: _confirmFocus,
      onModeChanged: _switchMode,
      onSubmit: _submit,
      onTogglePassword: () => setState(
        () => _obscurePassword = !_obscurePassword,
      ),
      onToggleConfirm: () => setState(
        () => _obscureConfirm = !_obscureConfirm,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final supabaseConfig = ref.watch(supabaseConfigProvider);
    final isLoading = _busy || authState.isLoading;
    final isReset = _mode == _AuthMode.resetPassword;
    final isSignUp = _mode == _AuthMode.signUp;
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final fieldStyle = AuthFormTheme.fieldTextStyle(context);

    ref.listen(authNotifierProvider, (previous, next) {
      next.whenOrNull(
        error: (error, _) {
          if (_mode == _AuthMode.resetPassword) return;
          AppMessenger.showAppError(
            context,
            error.toAppError(
              supabaseConfigured: supabaseConfig.isConfigured,
            ),
          );
        },
      );
    });

    final maxWidth = ResponsiveLayout.formMaxWidth(context);
    final horizontalPad = ResponsiveLayout.horizontalPadding(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: GradientBackground(
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, viewportConstraints) {
                final minContentHeight = math.max(
                  0.0,
                  viewportConstraints.maxHeight - AppSpacing.sm * 2,
                );

                return SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: minContentHeight),
                    child: Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPad,
                          vertical: AppSpacing.sm,
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: maxWidth),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (!supabaseConfig.isConfigured) ...[
                                const _ConfigWarningBanner(),
                                const SizedBox(height: AppSpacing.md),
                              ],
                              if (isDesktop)
                                _DesktopAuthLayout(
                                  form: _buildAuthForm(
                                    fieldStyle: fieldStyle,
                                    isLoading: isLoading,
                                    isReset: isReset,
                                    isSignUp: isSignUp,
                                  ),
                                )
                              else ...[
                                const _BrandHeader(compact: false),
                                const SizedBox(height: AppSpacing.lg),
                                _buildAuthForm(
                                  fieldStyle: fieldStyle,
                                  isLoading: isLoading,
                                  isReset: isReset,
                                  isSignUp: isSignUp,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthForm extends StatelessWidget {
  final _AuthMode mode;
  final GlobalKey<FormState> formKey;
  final TextStyle fieldStyle;
  final bool isLoading;
  final bool isReset;
  final bool isSignUp;
  final String? resetSentMessage;
  final String? signUpSentMessage;
  final bool obscurePassword;
  final bool obscureConfirm;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final FocusNode emailFocus;
  final FocusNode passwordFocus;
  final FocusNode confirmFocus;
  final ValueChanged<_AuthMode> onModeChanged;
  final VoidCallback onSubmit;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirm;

  const _AuthForm({
    required this.mode,
    required this.formKey,
    required this.fieldStyle,
    required this.isLoading,
    required this.isReset,
    required this.isSignUp,
    required this.resetSentMessage,
    required this.signUpSentMessage,
    required this.obscurePassword,
    required this.obscureConfirm,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.emailFocus,
    required this.passwordFocus,
    required this.confirmFocus,
    required this.onModeChanged,
    required this.onSubmit,
    required this.onTogglePassword,
    required this.onToggleConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AuthCard(
      child: Form(
        key: formKey,
        child: AutofillGroup(
          child: FocusTraversalGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Semantics(
                  label: 'Authentication mode',
                  child: SegmentedButton<_AuthMode>(
                    segments: const [
                      ButtonSegment(
                        value: _AuthMode.signIn,
                        label: Text('Sign in'),
                        icon: Icon(Icons.login, size: 18),
                      ),
                      ButtonSegment(
                        value: _AuthMode.signUp,
                        label: Text('Join'),
                        icon: Icon(Icons.person_add_outlined, size: 18),
                      ),
                      ButtonSegment(
                        value: _AuthMode.resetPassword,
                        label: Text('Reset'),
                        icon: Icon(Icons.lock_reset, size: 18),
                      ),
                    ],
                    selected: {mode},
                    onSelectionChanged: (s) => onModeChanged(s.first),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  isReset
                      ? 'Reset your password'
                      : isSignUp
                          ? 'Create your account'
                          : 'Welcome back',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  isReset
                      ? 'We\'ll email you a secure link to choose a new password.'
                      : 'Connect with loved ones through fun, meaningful conversations.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                ),
                const SizedBox(height: AppSpacing.md),
                _EmailField(
                  controller: emailController,
                  focusNode: emailFocus,
                  fieldStyle: fieldStyle,
                  isReset: isReset,
                  onSubmit: onSubmit,
                  onNext: () => passwordFocus.requestFocus(),
                ),
                if (!isReset) ...[
                  const SizedBox(height: AppSpacing.sm),
                  _PasswordField(
                    controller: passwordController,
                    focusNode: passwordFocus,
                    fieldStyle: fieldStyle,
                    obscure: obscurePassword,
                    isSignUp: isSignUp,
                    onToggleObscure: onTogglePassword,
                    onSubmit:
                        isSignUp ? () => confirmFocus.requestFocus() : onSubmit,
                  ),
                ],
                if (isSignUp) ...[
                  const SizedBox(height: AppSpacing.sm),
                  _PasswordField(
                    controller: confirmPasswordController,
                    focusNode: confirmFocus,
                    fieldStyle: fieldStyle,
                    obscure: obscureConfirm,
                    isSignUp: true,
                    isConfirm: true,
                    passwordController: passwordController,
                    onToggleObscure: onToggleConfirm,
                    onSubmit: onSubmit,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    'At least 8 characters',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
                if (resetSentMessage != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  _AuthInfoBanner(
                    message: resetSentMessage!,
                    icon: Icons.mark_email_read_outlined,
                  ),
                ],
                if (signUpSentMessage != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  _AuthInfoBanner(
                    message: signUpSentMessage!,
                    icon: Icons.mark_email_unread_outlined,
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                PrimaryButton(
                  label: isReset
                      ? 'Send reset link'
                      : isSignUp
                          ? 'Create account'
                          : 'Sign in',
                  onPressed: isLoading ? null : onSubmit,
                  isLoading: isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmailField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final TextStyle fieldStyle;
  final bool isReset;
  final VoidCallback onSubmit;
  final VoidCallback onNext;

  const _EmailField({
    required this.controller,
    required this.focusNode,
    required this.fieldStyle,
    required this.isReset,
    required this.onSubmit,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Email address',
      textField: true,
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        style: fieldStyle,
        keyboardType: TextInputType.emailAddress,
        textInputAction: isReset ? TextInputAction.done : TextInputAction.next,
        autofillHints: const [AutofillHints.email],
        autocorrect: false,
        enableSuggestions: false,
        decoration: const InputDecoration(
          labelText: 'Email',
          hintText: 'you@example.com',
          prefixIcon: Icon(Icons.email_outlined),
        ),
        validator: (value) {
          final email = value?.trim() ?? '';
          if (email.isEmpty) return 'Email is required';
          if (!email.contains('@') || !email.contains('.')) {
            return 'Enter a valid email address';
          }
          return null;
        },
        onFieldSubmitted: isReset ? (_) => onSubmit() : (_) => onNext(),
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final TextStyle fieldStyle;
  final bool obscure;
  final bool isSignUp;
  final bool isConfirm;
  final TextEditingController? passwordController;
  final VoidCallback onToggleObscure;
  final VoidCallback onSubmit;

  const _PasswordField({
    required this.controller,
    required this.focusNode,
    required this.fieldStyle,
    required this.obscure,
    required this.isSignUp,
    this.isConfirm = false,
    this.passwordController,
    required this.onToggleObscure,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: isConfirm ? 'Confirm password' : 'Password',
      textField: true,
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        style: fieldStyle,
        obscureText: obscure,
        textInputAction: TextInputAction.done,
        autofillHints: isSignUp
            ? const [AutofillHints.newPassword]
            : const [AutofillHints.password],
        decoration: InputDecoration(
          labelText: isConfirm ? 'Confirm password' : 'Password',
          hintText: isConfirm
              ? 'Re-enter your password'
              : isSignUp
                  ? 'Create a strong password'
                  : 'Enter your password',
          prefixIcon: const Icon(Icons.lock_outline),
          suffixIcon: IconButton(
            tooltip: obscure ? 'Show password' : 'Hide password',
            icon: Icon(
              obscure
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
            ),
            onPressed: onToggleObscure,
          ),
        ),
        validator: (value) {
          final password = value?.trim() ?? '';
          if (password.isEmpty) {
            return isConfirm
                ? 'Please confirm your password'
                : 'Password is required';
          }
          if (isConfirm && password != passwordController!.text.trim()) {
            return 'Passwords do not match';
          }
          if (!isConfirm && isSignUp && password.length < 8) {
            return 'Password must be at least 8 characters';
          }
          return null;
        },
        onFieldSubmitted: (_) => onSubmit(),
      ),
    );
  }
}

class _AuthInfoBanner extends StatelessWidget {
  final String message;
  final IconData icon;

  const _AuthInfoBanner({
    required this.message,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.softBlue,
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          border: Border.all(color: AppColors.vibrantGreen),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.vibrantGreen),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DesktopAuthLayout extends StatelessWidget {
  final Widget form;

  const _DesktopAuthLayout({required this.form});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: AppSpacing.lg),
            child: _BrandHeader(compact: true),
          ),
        ),
        Expanded(child: form),
      ],
    );
  }
}

class _ConfigWarningBanner extends StatelessWidget {
  const _ConfigWarningBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.softOrange,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        border: Border.all(color: AppColors.brightOrange, width: 1.5),
      ),
      child: Text(
        'Supabase is not configured. Copy .env.example to .env, '
        'add your credentials, then run: make run',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  final bool compact;

  const _BrandHeader({required this.compact});

  @override
  Widget build(BuildContext context) {
    final logoSize = compact ? 120.0 : 140.0;

    return Column(
      children: [
        Center(
          child: Hero(
            tag: 'girocall-logo',
            child: Container(
              height: logoSize,
              width: logoSize,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 24,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.contain,
                  semanticLabel: '${Constants.appName} logo',
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: compact ? AppSpacing.sm : AppSpacing.md),
        Text(
          Constants.appName,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: const [
              Shadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          Constants.tagline,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white.withValues(alpha: 0.95),
            height: 1.4,
            shadows: const [
              Shadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(0, 1),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
