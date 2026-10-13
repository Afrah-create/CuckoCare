import 'package:flutter/material.dart';

import '../../../app/router/navigator_keys.dart';
import 'feed_item_detail_screen.dart';

/// Navigation helpers for the feed feature.
/// Detail routes use rootNavigatorKey to hide the bottom bar.

class FeedItemDetailRoute {
  const FeedItemDetailRoute({required this.feedItemId});

  final String feedItemId;

  Future<T?> push<T>(BuildContext context) {
    return Navigator.of(
      rootNavigatorKey.currentContext ?? context,
      rootNavigator: true,
    ).push<T>(
      MaterialPageRoute<T>(
        builder: (_) => FeedItemDetailScreen(feedItemId: feedItemId),
        fullscreenDialog: false,
      ),
    );
  }
}
