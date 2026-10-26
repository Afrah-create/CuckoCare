import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/error/failure.dart';
import '../../../core/error/result.dart';
import '../../../data_platform/supabase/offline_first_auth.dart';
import '../domain/available_vet.dart';

export '../domain/available_vet.dart';

class VetDirectoryRepository {
  VetDirectoryRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<Result<List<AvailableVet>>> listAvailableVets({String? farmId}) async {
    if (!await ensureSupabaseSessionForNetwork()) {
      return const Error(SyncAuthRequired());
    }
    try {
      final raw = await _client.rpc(
        'list_available_vets',
        params: {'p_farm_id': ?farmId},
      );
      return Success(_parseVets(raw));
    } on PostgrestException catch (e) {
      return Error(mapPostgrestFailure(e));
    } catch (e) {
      return Error(UnexpectedFailure('$e'));
    }
  }

  static List<AvailableVet> _parseVets(Object? raw) {
    List<dynamic>? list;
    if (raw is Map) {
      final vets = raw['vets'];
      if (vets is List) {
        list = vets;
      }
    } else if (raw is List) {
      list = raw;
    }
    if (list == null) {
      return const [];
    }
    return list
        .whereType<Map>()
        .map((row) => AvailableVet.fromJson(Map<String, dynamic>.from(row)))
        .where((v) => v.userId.isNotEmpty)
        .toList();
  }
}

Failure mapPostgrestFailure(PostgrestException e) {
  return classifyPostgrest(code: e.code, message: e.message);
}

Failure classifyPostgrest({String? code, String? message}) {
  final c = (code ?? '').toUpperCase();
  final text = '${code ?? ''} ${message ?? ''}'.toLowerCase();
  if (c == 'PGRST202' || text.contains('schema cache') || text.contains('could not find the function')) {
    return const SyncServerFailure('PGRST202', retryable: false);
  }
  if (c == '42501' || text.contains('forbidden')) {
    return const PermissionFailure();
  }
  if (c == '28000' || text.contains('not authenticated')) {
    return const SyncAuthRequired();
  }
  return UnexpectedFailure(message ?? 'Request failed');
}
