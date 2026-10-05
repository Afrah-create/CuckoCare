import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/error/ui_failure.dart';
import '../../layout/content_frame.dart';
import '../../theme/app_spacing.dart';
import '../../theme/theme_context.dart';
import '../inline_banner.dart';

class ErrorState extends StatefulWidget {
  const ErrorState({
    required this.failure,
    this.onRetry,
    this.compact = false,
    super.key,
  });

  final UiFailure failure;
  final VoidCallback? onRetry;
  final bool compact;

  @override
  State<ErrorState> createState() => _ErrorStateState();
}

class _ErrorStateState extends State<ErrorState> {
  var _details = false;

  @override
  Widget build(BuildContext context) {
    final failure = widget.failure;
    if (widget.compact) {
      return InlineBanner(
        message: '${failure.title} ${failure.message}',
        icon: Icons.error_outline,
        tone: BannerTone.error,
      );
    }

    final body = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          _iconFor(failure.kind),
          size: 40,
          color: context.scheme.error,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          failure.title,
          style: context.text.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          failure.message,
          style: context.text.bodyMedium?.copyWith(
            color: context.scheme.onSurfaceVariant,
            height: 1.35,
          ),
          textAlign: TextAlign.center,
        ),
        if (widget.onRetry != null && failure.action == UiAction.retry) ...[
          const SizedBox(height: AppSpacing.lg),
          FilledButton(
            onPressed: widget.onRetry,
            child: const Text('Try again'),
          ),
        ],
        TextButton(
          onPressed: () => setState(() => _details = !_details),
          child: Text(_details ? 'Hide details' : 'Details'),
        ),
        if (_details)
          _Details(code: failure.code),
      ],
    );

    return ContentFrame(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(child: body),
            ),
          );
        },
      ),
    );
  }

  IconData _iconFor(UiFailureKind kind) {
    return switch (kind) {
      UiFailureKind.offline => Icons.cloud_off_outlined,
      UiFailureKind.timeout => Icons.hourglass_bottom,
      UiFailureKind.authRequired => Icons.lock_outline,
      UiFailureKind.permissionDenied ||
      UiFailureKind.permissionBlocked =>
        Icons.privacy_tip_outlined,
      UiFailureKind.notFound => Icons.search_off_outlined,
      _ => Icons.error_outline,
    };
  }
}

class _Details extends StatelessWidget {
  const _Details({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Expanded(
              child: SelectableText(
                'Code $code',
                style: context.text.bodySmall,
              ),
            ),
            IconButton(
              tooltip: 'Copy',
              onPressed: () {
                Clipboard.setData(ClipboardData(text: code));
              },
              icon: const Icon(Icons.copy, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}
