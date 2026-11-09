import 'package:flutter/material.dart';

import '../../layout/content_frame.dart';
import '../../layout/layout_scope.dart';
import '../../theme/app_spacing.dart';
import '../../theme/theme_context.dart';
import '../app_logo.dart';
import '../poultry_empty_art.dart';

enum EmptyKind { firstUse, filtered, cleared, permission }

class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.title,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.kind = EmptyKind.firstUse,
    this.actionLabel,
    this.onAction,
    this.secondaryLabel,
    this.onSecondary,
    this.showMark = false,
    super.key,
  });

  final String title;
  final String message;
  final IconData icon;
  final EmptyKind kind;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final bool showMark;

  @override
  Widget build(BuildContext context) {
    final compact = context.layout.isCompactHeight;
    final markSize = compact ? 64.0 : 104.0;

    final art = showMark
        ? Opacity(
            opacity: 0.85,
            child: AppLogo(
              size: compact ? AppLogoSize.small : AppLogoSize.medium,
            ),
          )
        : kind == EmptyKind.firstUse
        ? PoultryEmptyArt(size: compact ? 56 : 88)
        : _IconMedallion(icon: icon, kind: kind, compact: compact);

    final copy = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment:
          compact ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: context.text.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          textAlign: compact ? TextAlign.start : TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          message,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: context.text.bodyMedium?.copyWith(
            color: context.scheme.onSurfaceVariant,
            height: 1.35,
          ),
          textAlign: compact ? TextAlign.start : TextAlign.center,
        ),
        if (actionLabel != null && onAction != null) ...[
          const SizedBox(height: AppSpacing.lg),
          Align(
            alignment: compact ? Alignment.centerLeft : Alignment.center,
            child: FilledButton(
              onPressed: onAction,
              child: Text(actionLabel!),
            ),
          ),
        ],
        if (secondaryLabel != null && onSecondary != null)
          TextButton(onPressed: onSecondary, child: Text(secondaryLabel!)),
      ],
    );

    final body = compact
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              art,
              const SizedBox(width: AppSpacing.md),
              Expanded(child: copy),
            ],
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: markSize, child: Center(child: art)),
              const SizedBox(height: AppSpacing.lg),
              copy,
            ],
          );

    return ContentFrame(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final child = Center(child: body);
          if (!constraints.hasBoundedHeight) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: child,
            );
          }
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: child,
            ),
          );
        },
      ),
    );
  }
}

class _IconMedallion extends StatelessWidget {
  const _IconMedallion({
    required this.icon,
    required this.kind,
    required this.compact,
  });

  final IconData icon;
  final EmptyKind kind;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final scheme = context.scheme;
    final (background, foreground) = switch (kind) {
      EmptyKind.cleared => (colors.successContainer, colors.onSuccessContainer),
      EmptyKind.permission => (colors.warningContainer, colors.onWarningContainer),
      EmptyKind.filtered => (
          scheme.surfaceContainerHighest,
          scheme.onSurfaceVariant,
        ),
      EmptyKind.firstUse => (colors.emptyStateTint, scheme.primary),
    };
    final pad = compact ? 12.0 : 22.0;
    final size = compact ? 28.0 : 40.0;

    return DecoratedBox(
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      child: Padding(
        padding: EdgeInsets.all(pad),
        child: Icon(icon, size: size, color: foreground),
      ),
    );
  }
}
