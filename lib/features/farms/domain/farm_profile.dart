import '../../../data_platform/db/app_database.dart';

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
