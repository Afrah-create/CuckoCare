import 'package:flutter/material.dart';

import '../../../app/router/routes/typed_routes.dart';

/// Navigation helpers for the feed feature.
/// Uses typed GoRouter routes so the bottom bar is hidden on detail screens.
///
/// [FeedItemDetailRoute] sets `$parentNavigatorKey = rootNavigatorKey`, which
/// pushes the screen above the shell and hides the bottom navigation bar.
extension FeedItemDetailRouteX on FeedItemDetailRoute {
  /// Push the feed item detail screen.
  Future<T?> push<T extends Object?>(BuildContext context) =>
      FeedItemDetailRoute(feedItemId: feedItemId).push<T>(context);
}
