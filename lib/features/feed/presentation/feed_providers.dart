import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';
import '../data/feed_repository.dart';

/// Live stock levels for the primary farm.
final feedStockProvider = StreamProvider<List<FeedStockRow>>((ref) {
  final farmId = ref.watch(primaryFarmProvider).value?.id;
  if (farmId == null) {
    return Stream.value(const []);
  }
  return ref.watch(feedRepositoryProvider).watchStockLevelsCombined(farmId);
});

/// Transactions for a specific feed item.
final feedTransactionsProvider =
    StreamProvider.family<List<dynamic>, String>((ref, feedItemId) {
  return ref.watch(feedRepositoryProvider).watchTransactions(feedItemId);
});
