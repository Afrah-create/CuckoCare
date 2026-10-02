import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/error/failure.dart';
import '../../../core/error/result.dart';
import '../../../data_platform/supabase/offline_first_auth.dart';
import '../../farms/domain/farm_gps.dart';

class VetLocationRepository {
  VetLocationRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<Result<void>> saveCurrentLocation(FarmGpsReading reading) async {
    if (!await ensureSupabaseSessionForNetwork()) {
      return const Error(SyncAuthRequired());
    }
    try {
      await _client.rpc(
        'save_vet_location',
        params: {
          'p_latitude': reading.latitude,
          'p_longitude': reading.longitude,
          'p_accuracy_m': reading.accuracyMeters,
        },
      );
      return const Success(null);
    } on PostgrestException catch (e) {
      return Error(UnexpectedFailure(e.message));
    } catch (e) {
      return Error(UnexpectedFailure('$e'));
    }
  }
}
