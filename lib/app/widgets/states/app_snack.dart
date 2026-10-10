import 'package:flutter/material.dart';

import '../../theme/app_motion.dart';
import '../../theme/theme_context.dart';

enum AppSnackKind { success, info, error }

class AppSnack {
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> show(
    BuildContext context, {
    required String message,
    AppSnackKind kind = AppSnackKind.info,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    final motion = AppMotion.of(context);
    final hasAction = actionLabel != null && onAction != null;
    final colors = context.colors;
    final scheme = context.scheme;
    final background = switch (kind) {
      AppSnackKind.success => colors.successContainer,
      AppSnackKind.error => scheme.errorContainer,
      AppSnackKind.info => scheme.inverseSurface,
    };
    final foreground = switch (kind) {
      AppSnackKind.success => colors.onSuccessContainer,
      AppSnackKind.error => scheme.onErrorContainer,
      AppSnackKind.info => scheme.onInverseSurface,
    };

    return messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: hasAction ? motion.snackbarWithAction : motion.snackbarShort,
        backgroundColor: background,
        content: Text(
          message,
          style: context.text.bodyMedium?.copyWith(color: foreground),
        ),
        action: hasAction
            ? SnackBarAction(
                label: actionLabel,
                textColor: foreground,
                onPressed: onAction,
              )
            : null,
      ),
    );
  }

  static void success(BuildContext context, String message) {
    show(context, message: message, kind: AppSnackKind.success);
  }

  static void error(
    BuildContext context,
    String message, {
    VoidCallback? onRetry,
  }) {
    show(
      context,
      message: message,
      kind: AppSnackKind.error,
      actionLabel: onRetry == null ? null : 'Retry',
      onAction: onRetry,
    );
  }

  static void undo(
    BuildContext context, {
    required String message,
    required VoidCallback onUndo,
  }) {
    show(
      context,
      message: message,
      kind: AppSnackKind.info,
      actionLabel: 'Undo',
      onAction: onUndo,
    );
  }
}
