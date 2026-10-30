import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/error/failure.dart';
import '../../../core/error/result.dart';
import '../../../data_platform/supabase/offline_first_auth.dart';
import '../domain/available_vet.dart';

export '../domain/available_vet.dart';

final _uuid = RegExp(
  r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
);

class VetDirectoryRepository {
  VetDirectoryRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<Result<List<AvailableVet>>> listAvailableVets({String? farmId}) async {
    if (!await ensureSupabaseSessionForNetwork()) {
      return const Error(SyncAuthRequired());
    }
    final farm = (farmId != null && _uuid.hasMatch(farmId)) ? farmId : null;
    try {
      final raw = await _client.rpc(
        'list_available_vets',
        params: {
          'p_farm_id': farm,
          'p_limit': 50,
        },
      ).timeout(const Duration(seconds: 12));
      return Success(parseListAvailableVets(raw));
    } on PostgrestException catch (e) {
      final mapped = mapPostgrestFailure(e);
      if (mapped is PermissionFailure && farm != null) {
        try {
          final raw = await _client.rpc(
            'list_available_vets',
            params: {
              'p_farm_id': null,
              'p_limit': 50,
            },
          ).timeout(const Duration(seconds: 12));
          return Success(parseListAvailableVets(raw));
        } on PostgrestException catch (e2) {
          return Error(mapPostgrestFailure(e2));
        }
      }
      return Error(mapped);
    } catch (e) {
      final text = '$e'.toLowerCase();
      if (text.contains('timeout')) {
        return const Error(SyncTimeout());
      }
      return Error(UnexpectedFailure('$e'));
    }
  }
}

List<AvailableVet> parseListAvailableVets(Object? raw) {
  var payload = raw;
  if (payload is String && payload.isNotEmpty) {
    try {
      payload = jsonDecode(payload);
    } catch (_) {
      return const [];
    }
  }
  if (payload is Map && payload['list_available_vets'] != null) {
    return parseListAvailableVets(payload['list_available_vets']);
  }
  List<dynamic>? list;
  if (payload is Map) {
    final vets = payload['vets'];
    if (vets is List) {
      list = vets;
    } else if (vets is String) {
      try {
        final decoded = jsonDecode(vets);
        if (decoded is List) {
          list = decoded;
        }
      } catch (_) {}
    }
  } else if (payload is List) {
    list = payload;
  }
  if (list == null) {
    return const [];
  }
  final out = <AvailableVet>[];
  for (final row in list) {
    if (row is! Map) {
      continue;
    }
    try {
      final vet = AvailableVet.fromJson(Map<String, dynamic>.from(row));
      if (vet.userId.isNotEmpty) {
        out.add(vet);
      }
    } catch (_) {}
  }
  return out;
}

Failure mapPostgrestFailure(PostgrestException e) {
  return classifyPostgrest(code: e.code, message: e.message);
}

Failure classifyPostgrest({String? code, String? message}) {
  final c = (code ?? '').toUpperCase();
  final text = '${code ?? ''} ${message ?? ''}'.toLowerCase();
  if (c == 'PGRST202' ||
      c == 'PGRST203' ||
      text.contains('schema cache') ||
      text.contains('could not find the function') ||
      text.contains('could not choose the best candidate function') ||
      text.contains('ambiguous')) {
    return const SyncServerFailure('PGRST202', retryable: false);
  }
  if (c == '42501' || text.contains('forbidden')) {
    return const PermissionFailure();
  }
  if (c == '28000' || text.contains('not authenticated')) {
    return const SyncAuthRequired();
  }
  if (c == '22P02' || text.contains('invalid input syntax')) {
    return const ValidationFailure('Farm is not synced yet.');
  }
  return UnexpectedFailure(message ?? 'Request failed');
}
