import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/splash/splash_controller.dart';
import '../di/providers.dart';

/// Bridges Riverpod auth loading to go_router without recreating [GoRouter].
class RouterRefresh extends ChangeNotifier {
  void notifyRouter() => notifyListeners();
}

final routerRefreshProvider = Provider<RouterRefresh>((ref) {
  final refresh = RouterRefresh();
  ref.listen(hasAuthSnapshotProvider, (_, _) => refresh.notifyRouter());
  ref.listen(splashIntroCompleteProvider, (_, _) => refresh.notifyRouter());
  return refresh;
});
