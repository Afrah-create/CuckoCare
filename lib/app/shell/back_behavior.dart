import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

/// Android back: pop stack → non-start tab goes to Today → exit app.
void handleShellBack({
  required GoRouter router,
  required int currentTabIndex,
  required void Function() goToTodayTab,
}) {
  if (router.canPop()) {
    router.pop();
    return;
  }
  if (currentTabIndex != 0) {
    goToTodayTab();
    return;
  }
  SystemNavigator.pop();
}
