import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/splash/splash_controller.dart';
import '../di/providers.dart';

/// Bridges Riverpod auth loading to go_router without recreating [GoRouter].
class RouterRefresh extends ChangeNotifier {
  bool _notifyScheduled = false;

  /// Coalesce auth-driven redirects to one pass per frame (avoids overlapping
  /// shell mounts and duplicate branch [GlobalKey]s).
  void notifyRouter() {
    if (_notifyScheduled) {
      return;
    }
    _notifyScheduled = true;
    SchedulerBinding.instance.scheduleFrameCallback((_) {
      _notifyScheduled = false;
      notifyListeners();
    });
  }
}

final routerRefreshProvider = Provider<RouterRefresh>((ref) {
  final refresh = RouterRefresh();
  ref.listen(hasAuthSnapshotProvider, (previous, next) {
    if (next.isLoading) {
      return;
    }
    if (previous?.hasValue == true &&
        next.hasValue &&
        previous!.requireValue == next.requireValue) {
      return;
    }
    refresh.notifyRouter();
  });
  ref.listen(splashIntroCompleteProvider, (_, _) => refresh.notifyRouter());
  ref.listen(appRoleProvider, (previous, next) {
    if (next.isLoading) {
      return;
    }
    if (previous?.hasValue == true &&
        next.hasValue &&
        previous!.requireValue == next.requireValue) {
      return;
    }
    refresh.notifyRouter();
  });
  return refresh;
});
