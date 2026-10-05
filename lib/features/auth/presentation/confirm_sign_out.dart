import 'package:flutter/material.dart';

import '../../../app/widgets/cuco_confirm_dialog.dart';

Future<bool> confirmSignOut(BuildContext context) async {
  final ok = await showCucoConfirmBottomSheet(
    context: context,
    title: 'Sign out?',
    message: 'Are you sure you want to sign out?',
    confirmLabel: 'Sign out',
    cancelLabel: 'Stay signed in',
    destructive: true,
  );
  return ok == true;
}
