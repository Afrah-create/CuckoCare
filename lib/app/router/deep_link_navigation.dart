import 'package:go_router/go_router.dart';

/// Keeps the tab shell visible and pushes detail routes on the root stack.
Future<void> navigateAuthenticatedDeepLink(GoRouter router, String path) async {
  final uri = Uri.parse(path);
  final location = uri.hasQuery ? '${uri.path}?${uri.query}' : uri.path;

  const tabPaths = {'/today', '/batches', '/feed', '/records', '/more'};
  if (tabPaths.contains(uri.path)) {
    router.go(location);
    return;
  }

  var shellTab = '/today';
  if (uri.path.startsWith('/batches')) {
    shellTab = '/batches';
  } else if (uri.path.startsWith('/more')) {
    shellTab = '/more';
  } else if (uri.path.startsWith('/records')) {
    shellTab = '/records';
  } else if (uri.path.startsWith('/feed')) {
    shellTab = '/feed';
  }

  router.go(shellTab);
  await Future<void>.delayed(Duration.zero);
  router.push(location);
}
