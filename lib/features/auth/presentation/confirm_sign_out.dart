import 'package:flutter/material.dart';

import '../../../app/widgets/cuco_confirm_dialog.dart';

Future<bool> confirmSignOut(BuildContext context) async {
  final ok = await showCucoConfirmBottomSheet(
    context: context,
    title: 'Sign out?',
    message: 'You will need to sign in again to sync and view your farm data.',
    confirmLabel: 'Sign out',
    cancelLabel: 'Stay signed in',
    destructive: true,
  );
  return ok == true;
}
