import 'package:flutter/material.dart';

import '../cuco_confirm_dialog.dart';

class AppDialog extends StatelessWidget {
  const AppDialog({
    required this.title,
    this.message,
    this.content,
    this.icon,
    this.actions = const [],
    super.key,
  });

  final Widget title;
  final String? message;
  final Widget? content;
  final Widget? icon;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: icon,
      title: title,
      content: content ?? (message == null ? null : Text(message!)),
      actions: actions,
    );
  }
}

Future<T?> showAppDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: builder,
  );
}

Future<bool?> showConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
  bool destructive = false,
}) {
  return showCucoConfirmDialog(
    context: context,
    title: title,
    message: message,
    confirmLabel: confirmLabel,
    cancelLabel: cancelLabel,
    destructive: destructive,
  );
}
