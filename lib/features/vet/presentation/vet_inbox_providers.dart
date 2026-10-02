import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';
import '../../../core/error/result.dart';
import '../data/vet_inbox_repository.dart';

final vetInboxProvider =
    FutureProvider.autoDispose<List<VetInboxItem>>((ref) async {
  final result = await ref.watch(vetInboxRepositoryProvider).fetchInbox();
  return switch (result) {
    Success(value: final items) => items,
    Error(failure: final f) => throw Exception(f.message),
  };
});

bool vetInboxItemIsPending(VetInboxItem item) {
  return item.status == 'submitted' || item.status == 'received';
}

bool vetInboxItemIsActive(VetInboxItem item) {
  return item.status == 'accepted' || item.status == 'in_progress';
}
