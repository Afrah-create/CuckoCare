import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/widgets/app_primary_button.dart';
import '../../../app/widgets/app_text_field.dart';
import 'auth_card.dart';
import 'auth_mode_switch.dart';
import 'login_state.dart';

class ForgotPasswordForm extends StatefulWidget {
  const ForgotPasswordForm({super.key});

  @override
  State<ForgotPasswordForm> createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<ForgotPasswordForm> {
  final _emailController = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final body = _sent
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'If an account exists for that email, we sent a reset link.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppPrimaryButton(
                label: 'Back to sign in',
                onPressed: () => context.go('/auth/login'),
              ),
            ],
          )
        : Column(
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
                validator: (v) {
                  final t = v?.trim() ?? '';
                  if (t.isEmpty || !t.contains('@')) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              AppPrimaryButton(
                label: 'Send reset link',
                onPressed: () => setState(() => _sent = true),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: () => context.go('/auth/login'),
                child: const Text('Back to sign in'),
              ),
            ],
          );

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
