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
