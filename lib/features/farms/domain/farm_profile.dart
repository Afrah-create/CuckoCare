import '../../../data_platform/db/app_database.dart';
import 'farm_gps.dart';

/// Required before cloud sync treats the farm as production-ready.
bool isFarmProfileComplete(FarmRow? farm) {
  if (farm == null) {
    return false;
  }
  if (farm.deletedAt != null) {
    return false;
  }
  return farm.name.trim().isNotEmpty &&
      (farm.district?.trim().isNotEmpty ?? false) &&
      (farm.village?.trim().isNotEmpty ?? false) &&
      (farm.phone?.trim().isNotEmpty ?? false);
}

/// Farm the farmer is looking at.
///
/// A local save clears [FarmRow.serverVersion] until the row syncs. That must
/// not hide the farm just written behind an older synced stub.
FarmRow? selectPrimaryFarm(List<FarmRow> rows, List<String> snapshotIds) {
  if (rows.isEmpty) {
    return null;
  }
  final byId = {for (final row in rows) row.id: row};
  final scoped = <FarmRow>[
    for (final id in snapshotIds)
      if (byId.containsKey(id)) byId[id]!,
  ];
  final candidates = List<FarmRow>.from(scoped.isNotEmpty ? scoped : rows);
  candidates.sort(_primaryFarmOrder);
  return candidates.first;
}

int _primaryFarmOrder(FarmRow a, FarmRow b) {
  final aComplete = isFarmProfileComplete(a);
  final bComplete = isFarmProfileComplete(b);
  if (aComplete != bComplete) {
    return aComplete ? -1 : 1;
  }
  final aSynced = a.serverVersion != null;
  final bSynced = b.serverVersion != null;
  if (aSynced != bSynced) {
    return aSynced ? -1 : 1;
  }
  return b.updatedAt.compareTo(a.updatedAt);
}

bool farmHasGps(FarmRow? farm) {
  if (farm == null) {
    return false;
  }
  return farm.latitude != null && farm.longitude != null;
}

FarmGpsReading? gpsReadingFromFarm(FarmRow farm) {
  final lat = farm.latitude;
  final lng = farm.longitude;
  if (lat == null || lng == null) {
    return null;
  }
  return FarmGpsReading(
    latitude: lat,
    longitude: lng,
    accuracyMeters: farm.locationAccuracyM,
    capturedAt: farm.locationCapturedAt ?? farm.updatedAt,
  );
}
