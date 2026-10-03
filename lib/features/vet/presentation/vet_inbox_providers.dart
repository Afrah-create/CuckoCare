import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';
import '../../../core/error/result.dart';
import '../data/vet_directory_repository.dart';
import '../data/vet_inbox_repository.dart';
import '../data/vet_map_repository.dart';
import '../domain/vet_request_visibility.dart';

final vetInboxProvider = FutureProvider<List<VetInboxItem>>((ref) async {
  ref.watch(connectivityOnlineProvider);
  final result = await ref.read(vetInboxRepositoryProvider).fetchInbox();
  return switch (result) {
    Success(value: final items) => items,
    Error(failure: final f) => throw Exception(f.message),
  };
});

final vetMapProvider = FutureProvider<List<VetMapRequest>>((ref) async {
  ref.watch(connectivityOnlineProvider);
  final result = await ref.read(vetMapRepositoryProvider).fetchMapRequests();
  return switch (result) {
    Success(value: final items) => items,
    Error(failure: final f) => throw Exception(f.message),
  };
});

final availableVetsProvider =
    FutureProvider.family<List<AvailableVet>, String?>((ref, farmId) async {
  ref.watch(connectivityOnlineProvider);
  final result =
      await ref.read(vetDirectoryRepositoryProvider).listAvailableVets(
            farmId: farmId,
          );
  return switch (result) {
    Success(value: final vets) => vets,
    Error(failure: final f) => throw Exception(f.message),
  };
});

bool vetInboxItemIsPending(VetInboxItem item, String vetUserId) {
  return vetInboxItemIsPendingForVet(
    status: item.status,
    assignedVetUserId: item.assignedVetUserId,
    requestedVetUserId: item.requestedVetUserId,
    vetUserId: vetUserId,
  );
}

bool vetInboxItemIsActive(VetInboxItem item, String vetUserId) {
  return vetInboxItemIsActiveForVet(
    status: item.status,
    assignedVetUserId: item.assignedVetUserId,
    vetUserId: vetUserId,
  );
}
