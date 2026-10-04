import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../di/providers.dart';
import 'deep_link_navigation.dart';

/// Routes notification and `cucocare://` links after the session gate resolves.
class DeepLinkHandler {
  DeepLinkHandler(this._ref);

  final Ref _ref;
  String? _pendingPath;

  void enqueue(String? path) {
    if (path == null || path.isEmpty) {
      return;
    }
    _pendingPath = path.startsWith('/') ? path : '/$path';
  }

  Future<void> flush(GoRouter router) async {
    final path = _pendingPath;
    if (path == null) {
      return;
    }
    _pendingPath = null;

    final authed = await _ref.read(hasAuthSnapshotProvider.future);
    if (!authed) {
      router.go('/auth/login?from=${Uri.encodeComponent(path)}');
      return;
    }
    await navigateAuthenticatedDeepLink(router, path);
  }
}

final deepLinkHandlerProvider = Provider<DeepLinkHandler>((ref) {
  return DeepLinkHandler(ref);
});
