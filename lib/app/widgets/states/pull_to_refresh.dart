import 'package:flutter/material.dart';

import '../../theme/app_motion.dart';
import 'app_snack.dart';

class PullToRefresh extends StatelessWidget {
  const PullToRefresh({
    required this.onSync,
    required this.child,
    this.online = true,
    super.key,
  });

  final Future<void> Function() onSync;
  final Widget child;
  final bool online;

  Future<void> _refresh(BuildContext context) async {
    await onSync();
    if (!context.mounted) {
      return;
    }
    AppSnack.show(
      context,
      message: online ? 'Up to date' : 'Offline. Will sync later',
      kind: AppSnackKind.info,
    );
  }

  @override
  Widget build(BuildContext context) {
    final motion = AppMotion.of(context);
    return RefreshIndicator(
      onRefresh: () => _refresh(context),
      displacement: motion.reduceMotion ? 0 : 40,
      child: child,
    );
  }
}
