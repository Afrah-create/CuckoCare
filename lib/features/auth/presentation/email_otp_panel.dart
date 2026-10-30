import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../../app/widgets/app_primary_button.dart';
import '../../../app/widgets/inline_banner.dart';
import '../domain/auth_repository.dart';

class EmailOtpPanel extends StatefulWidget {
  const EmailOtpPanel({
    required this.email,
    required this.purpose,
    required this.submitting,
    required this.onVerify,
    required this.onResend,
    required this.onBack,
    this.errorMessage,
    this.infoMessage,
    this.onDismissError,
    this.onDismissInfo,
    super.key,
  });

  final String email;
  final EmailOtpPurpose purpose;
  final bool submitting;
  final Future<void> Function(String code) onVerify;
  final VoidCallback onResend;
  final VoidCallback onBack;
  final String? errorMessage;
  final String? infoMessage;
  final VoidCallback? onDismissError;
  final VoidCallback? onDismissInfo;

  @override
  State<EmailOtpPanel> createState() => _EmailOtpPanelState();
}

class _EmailOtpPanelState extends State<EmailOtpPanel> {
  final _code = TextEditingController();

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final code = _code.text.trim();
    if (code.length != 6) {
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    await widget.onVerify(code);
  }

  @override
  Widget build(BuildContext context) {
    final heading = widget.purpose == EmailOtpPurpose.passwordReset
        ? 'Enter the reset code'
        : 'Verify your email';
    final masked = widget.email;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(heading, style: context.text.titleMedium),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'We sent a 6-digit code to $masked. It expires in 10 minutes.',
          style: context.text.bodyMedium?.copyWith(
            color: context.scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        TextField(
          controller: _code,
          enabled: !widget.submitting,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.oneTimeCode],
          maxLength: 6,
          textAlign: TextAlign.center,
          style: context.text.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 10,
          ),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            counterText: '',
            hintText: '••••••',
            labelText: '6-digit code',
          ),
          onChanged: (value) {
            if (value.length == 6) {
              _submit();
            }
          },
          onSubmitted: (_) => _submit(),
        ),
        if (widget.infoMessage != null) ...[
          const SizedBox(height: AppSpacing.sm),
          InlineBanner(
            message: widget.infoMessage!,
            icon: Icons.mark_email_read_outlined,
            onDismiss: widget.onDismissInfo,
          ),
        ],
        if (widget.errorMessage != null) ...[
          const SizedBox(height: AppSpacing.sm),
          InlineBanner(
            message: widget.errorMessage!,
            icon: Icons.error_outline,
            onDismiss: widget.onDismissError,
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        AppPrimaryButton(
          label: 'Verify',
          loading: widget.submitting,
          onPressed: widget.submitting ? null : _submit,
        ),
        const SizedBox(height: AppSpacing.sm),
        TextButton(
          onPressed: widget.submitting ? null : widget.onResend,
          child: const Text('Resend code'),
        ),
        TextButton(
          onPressed: widget.submitting ? null : widget.onBack,
          child: const Text('Use a different email'),
        ),
      ],
    );
  }
}
