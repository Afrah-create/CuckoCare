import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/di/providers.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/widgets/app_primary_button.dart';
import '../../../app/widgets/app_text_field.dart';
import '../../../app/widgets/inline_banner.dart';
import '../../../core/error/result.dart';
import '../../../core/error/user_messages.dart';
import '../domain/auth_repository.dart';
import 'auth_card.dart';
import 'auth_mode_switch.dart';
import 'email_otp_panel.dart';
import 'login_state.dart';

enum _ResetStep { email, code, password }

class ForgotPasswordForm extends ConsumerStatefulWidget {
  const ForgotPasswordForm({super.key});

  @override
  ConsumerState<ForgotPasswordForm> createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends ConsumerState<ForgotPasswordForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _codeController = TextEditingController();
  _ResetStep _step = _ResetStep.email;
  bool _busy = false;
  String? _error;
  String? _info;
  bool _obscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = 'Enter a valid email');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await ref.read(authRepositoryProvider).requestEmailOtp(
          email: email,
          purpose: EmailOtpPurpose.passwordReset,
        );
    if (!mounted) {
      return;
    }
    switch (result) {
      case Error(:final failure):
        setState(() {
          _busy = false;
          _error = userMessageForFailure(failure);
        });
      case Success():
        setState(() {
          _busy = false;
          _step = _ResetStep.code;
          _info = 'If that email is registered, a 6-digit code is on the way.';
        });
    }
  }

  Future<void> _verifyCode(String code) async {
    if (code.length != 6) {
      return;
    }
    setState(() {
      _codeController.text = code;
      _step = _ResetStep.password;
      _error = null;
    });
  }

  Future<void> _savePassword() async {
    final password = _passwordController.text;
    if (password.length < 8) {
      setState(() => _error = 'Use at least 8 characters');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await ref.read(authRepositoryProvider).verifyEmailOtp(
          email: _emailController.text.trim(),
          code: _codeController.text.trim(),
          purpose: EmailOtpPurpose.passwordReset,
          newPassword: password,
        );
    if (!mounted) {
      return;
    }
    switch (result) {
      case Error(:final failure):
        setState(() {
          _busy = false;
          _error = userMessageForFailure(failure);
          if (failure.message.toLowerCase().contains('code')) {
            _step = _ResetStep.code;
          }
        });
      case Success():
        setState(() => _busy = false);
        ref.read(hasAuthSnapshotProvider.notifier).adoptAuthenticated();
        ref.invalidate(userProfileProvider);
        ref.invalidate(appRoleProvider);
        ref.invalidate(farmProfileIncompleteProvider);
        ref.invalidate(primaryFarmProvider);
        ref.invalidate(syncStatusProvider);
        ref.read(syncSchedulerProvider).onForeground();
        if (mounted) {
          context.go('/auth/login');
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    late final Widget body;
    switch (_step) {
      case _ResetStep.email:
        body = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              controller: _emailController,
              label: 'Email',
              leadingIcon: Icons.mail_outline_rounded,
              exampleHint: 'you@example.com',
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              autocorrect: false,
              enabled: !_busy,
              validator: (v) {
                final t = v?.trim() ?? '';
                if (t.isEmpty || !t.contains('@')) {
                  return 'Enter a valid email';
                }
                return null;
              },
            ),
            if (_error != null) ...[
              const SizedBox(height: AppSpacing.sm),
              InlineBanner(
                message: _error!,
                icon: Icons.error_outline,
                onDismiss: () => setState(() => _error = null),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            AppPrimaryButton(
              label: 'Send 6-digit code',
              loading: _busy,
              onPressed: _busy ? null : _sendCode,
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: _busy ? null : () => context.go('/auth/login'),
              child: const Text('Back to sign in'),
            ),
          ],
        );
      case _ResetStep.code:
        body = EmailOtpPanel(
          email: _emailController.text.trim(),
          purpose: EmailOtpPurpose.passwordReset,
          submitting: _busy,
          errorMessage: _error,
          infoMessage: _info,
          onDismissError: () => setState(() => _error = null),
          onDismissInfo: () => setState(() => _info = null),
          onVerify: _verifyCode,
          onResend: _sendCode,
          onBack: () => setState(() {
            _step = _ResetStep.email;
            _error = null;
            _info = null;
          }),
        );
      case _ResetStep.password:
        body = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PasswordField(
              controller: _passwordController,
              label: 'New password',
              obscured: _obscure,
              onToggleVisibility: () => setState(() => _obscure = !_obscure),
              enabled: !_busy,
              autofillHints: const [AutofillHints.newPassword],
              exampleHint: 'At least 8 characters',
              validator: (value) {
                if (value == null || value.length < 8) {
                  return 'At least 8 characters';
                }
                return null;
              },
            ),
            if (_error != null) ...[
              const SizedBox(height: AppSpacing.sm),
              InlineBanner(
                message: _error!,
                icon: Icons.error_outline,
                onDismiss: () => setState(() => _error = null),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            AppPrimaryButton(
              label: 'Save new password',
              loading: _busy,
              onPressed: _busy ? null : _savePassword,
            ),
          ],
        );
    }

    return AuthCard(
      header: 'Poultry records that work offline.',
      modeSwitch: AuthModeSwitch(
        mode: AuthFormMode.signIn,
        enabled: false,
        onChanged: (_) {},
      ),
      body: body,
    );
  }
}
