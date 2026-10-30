import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';
import '../../../core/error/failure.dart';
import '../../../core/error/result.dart';
import '../../farms/domain/farm_profile.dart';
import '../data/vet_directory_repository.dart';
import '../data/vet_inbox_repository.dart';
import '../data/vet_map_repository.dart';
import '../data/vet_profile_repository.dart';
import '../domain/available_vet.dart';
import '../domain/vet_profile.dart';
import '../domain/vet_request_visibility.dart';

final vetInboxProvider = FutureProvider<List<VetInboxItem>>((ref) async {
  ref.watch(connectivityOnlineProvider);
  final result = await ref.read(vetInboxRepositoryProvider).fetchInbox();
  return switch (result) {
    Success(value: final items) => items,
    Error(failure: final f) => throw f,
  };
});

final vetMapProvider = FutureProvider<List<VetMapRequest>>((ref) async {
  ref.watch(connectivityOnlineProvider);
  final result = await ref.read(vetMapRepositoryProvider).fetchMapRequests();
  return switch (result) {
    Success(value: final items) => items,
    Error(failure: final f) => throw f,
  };
});

final availableVetsProvider =
    FutureProvider.family<AvailableVetsBrowse, String?>((ref, farmId) async {
  ref.watch(connectivityOnlineProvider);
  final profile = await ref.watch(userProfileProvider.future);
  if (profile?.isDemo ?? false) {
    throw const SyncSignedOutDemo();
  }

  final farm = await ref.watch(primaryFarmProvider.future);
  final resolvedFarmId = farmId ?? farm?.id;
  final farmIdLooksSynced = resolvedFarmId != null &&
      RegExp(
        r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
      ).hasMatch(resolvedFarmId);
  final farmHasLocation =
      farm != null && farm.id == resolvedFarmId && farmHasGps(farm);
  final farmNeedsSync = !farmIdLooksSynced ||
      (farm != null && farm.id == resolvedFarmId && farm.serverVersion == null);
  final cacheKey = resolvedFarmId ?? '_none';
  final cache = ref.read(vetDirectoryCacheProvider);
  final repo = ref.read(vetDirectoryRepositoryProvider);
  final online = ref.watch(connectivityOnlineProvider).value ?? true;

  Future<AvailableVetsBrowse?> fromCache({required bool needsSync}) async {
    final cached = await cache.load(cacheKey);
    if (cached == null) {
      return null;
    }
    return AvailableVetsBrowse(
      vets: cached.vets,
      fetchedAt: cached.fetchedAt,
      fromCache: true,
      farmHasLocation: farmHasLocation,
      farmNeedsSync: needsSync,
    );
  }

  Future<Result<List<AvailableVet>>> fetch(String? id) {
    return repo.listAvailableVets(farmId: id);
  }

  if (!online) {
    final cached = await fromCache(needsSync: farmNeedsSync);
    if (cached != null) {
      return cached;
    }
    throw const SyncOffline();
  }

  var idToQuery = farmNeedsSync ? null : resolvedFarmId;
  var needsSync = farmNeedsSync;
  var result = await fetch(idToQuery);
  if (result case Error(failure: PermissionFailure())
      when resolvedFarmId != null && idToQuery != null) {
    needsSync = true;
    result = await fetch(null);
  }

  switch (result) {
    case Success(value: final vets):
      final now = DateTime.now().toUtc();
      await cache.save(farmKey: cacheKey, vets: vets, fetchedAt: now);
      return AvailableVetsBrowse(
        vets: vets,
        fetchedAt: now,
        fromCache: false,
        farmHasLocation: farmHasLocation,
        farmNeedsSync: needsSync,
      );
    case Error(failure: final f):
      final cached = await fromCache(needsSync: needsSync);
      if (cached != null) {
        return cached;
      }
      throw f;
  }
});

final vetProfileRepositoryProvider = Provider<VetProfileRepository>((ref) {
  return VetProfileRepository();
});

final vetProfileProvider = FutureProvider<VetProfile>((ref) async {
  ref.watch(connectivityOnlineProvider);
  final result = await ref.read(vetProfileRepositoryProvider).fetchProfile();
  return switch (result) {
    Success(value: final profile) => profile,
    Error(failure: final f) => throw f,
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
