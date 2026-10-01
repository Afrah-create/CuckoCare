import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/widgets/app_primary_button.dart';
import '../../../app/widgets/app_text_field.dart';
import '../../../app/widgets/inline_banner.dart';
import '../../../app/widgets/requirement_chips.dart';
import '../domain/auth_repository.dart';
import 'auth_card.dart';
import 'auth_mode_switch.dart';
import 'login_controller.dart';
import 'login_state.dart';

class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({super.key});

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  AuthFormMode? _lastMode;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final login = ref.read(loginControllerProvider);
    final AuthSessionResult? session;
    if (login.formMode == AuthFormMode.signUp) {
      session = await ref.read(loginControllerProvider.notifier).signUpWithEmail(
            email: _emailController.text,
            password: _passwordController.text,
            displayName: _displayNameController.text,
          );
    } else {
      session = await ref.read(loginControllerProvider.notifier).signInWithEmail(
            email: _emailController.text,
            password: _passwordController.text,
          );
    }

    if (session != null && mounted) {
      FocusManager.instance.primaryFocus?.unfocus();
      TextInput.finishAutofillContext(shouldSave: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final login = ref.watch(loginControllerProvider);
    final isSignUp = login.formMode == AuthFormMode.signUp;

    if (_lastMode != null && _lastMode != login.formMode) {
      _passwordController.clear();
    }
    _lastMode = login.formMode;

    final offlineBanner = !login.isOnline
        ? InlineBanner(
            message:
                "You're offline. Your first sign-in needs internet.",
            icon: Icons.cloud_off_outlined,
            onDismiss: null,
          )
        : null;

    final errorBanner = login.errorMessage != null
        ? InlineBanner(
            message: login.errorMessage!,
            icon: Icons.error_outline,
            onDismiss: () =>
                ref.read(loginControllerProvider.notifier).clearError(),
          )
        : null;

    final formBody = Form(
      key: _formKey,
      child: AutofillGroup(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.02),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: Column(
            key: ValueKey(isSignUp),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isSignUp) ...[
                AppTextField(
                  controller: _displayNameController,
                  label: 'Your name (optional)',
                  leadingIcon: Icons.person_outline_rounded,
                  exampleHint: 'How should we greet you?',
                  enabled: !login.isSubmitting,
                  textCapitalization: TextCapitalization.words,
                  autofillHints: const [AutofillHints.name],
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    final t = v?.trim() ?? '';
                    if (t.length > 60) {
                      return 'At most 60 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              AppTextField(
                controller: _emailController,
                label: 'Email',
                leadingIcon: Icons.mail_outline_rounded,
                exampleHint: 'you@example.com',
                enabled: !login.isSubmitting,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                autocorrect: false,
                validator: (value) {
                  final v = value?.trim() ?? '';
                  if (v.isEmpty) {
                    return 'Required';
                  }
                  if (!v.contains('@')) {
                    return 'Invalid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              PasswordField(
                controller: _passwordController,
                label: 'Password',
                obscured: login.obscurePassword,
                onToggleVisibility: () => ref
                    .read(loginControllerProvider.notifier)
                    .togglePasswordVisibility(),
                enabled: !login.isSubmitting,
                textInputAction: TextInputAction.done,
                autofillHints: isSignUp
                    ? const [AutofillHints.newPassword]
                    : const [AutofillHints.password],
                exampleHint: isSignUp ? 'At least 8 characters' : null,
                onFieldSubmitted: (_) => _submit(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  if (value.length < 8) {
                    return 'At least 8 characters';
                  }
                  return null;
                },
              ),
              if (isSignUp) ...[
                const SizedBox(height: AppSpacing.sm),
                PasswordRequirementChip(
                  met: _passwordController.text.length >= 8,
                ),
              ],
              if (!isSignUp) ...[
                const SizedBox(height: AppSpacing.xs),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: login.isSubmitting
                        ? null
                        : () => context.push('/auth/forgot-password'),
                    child: const Text('Forgot password?'),
                  ),
                ),
              ],
              if (offlineBanner != null) ...[
                const SizedBox(height: AppSpacing.sm),
                offlineBanner,
              ],
              if (errorBanner != null) ...[
                const SizedBox(height: AppSpacing.sm),
                errorBanner,
              ],
              const SizedBox(height: AppSpacing.lg),
              AppPrimaryButton(
                label: isSignUp ? 'Create account' : 'Sign in',
                loading: login.isSubmitting,
                onPressed: login.isSubmitting || !login.isOnline
                    ? null
                    : _submit,
              ),
            ],
          ),
        ),
      ),
    );

    return AuthCard(
      header: 'Poultry records that work offline.',
      modeSwitch: AuthModeSwitch(
        mode: login.formMode,
        enabled: !login.isSubmitting,
        onChanged: (mode) {
          ref.read(loginControllerProvider.notifier).setFormMode(mode);
        },
      ),
      body: formBody,
    );
  }
}
