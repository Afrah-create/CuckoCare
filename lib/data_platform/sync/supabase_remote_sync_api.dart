import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/error/result.dart';
import '../supabase/supabase_bootstrap.dart';
import 'remote_sync_api.dart';
import '../../core/error/failure.dart';

class SupabaseRemoteSyncApi implements RemoteSyncApi {
  SupabaseRemoteSyncApi({SupabaseClient? client}) : _client = client ?? supabaseClient;

  final SupabaseClient _client;

  static const _pushTimeout = Duration(seconds: 20);
  static const _pullTimeout = Duration(seconds: 15);

  @override
  Future<Result<bool>> ping() async {
    try {
      await _client
          .rpc('sync_head', params: {
            'p_scopes': ['reference'],
          })
          .timeout(const Duration(seconds: 10));
      return const Success(true);
    } on AuthException {
      return const Error(SyncAuthRequired());
    } on TimeoutException {
      return const Error(SyncTimeout());
    } catch (_) {
      return const Error(SyncOffline());
    }
  }

  @override
  Future<Result<SyncBootstrapData>> bootstrap() async {
    try {
      final raw = await _client.rpc('sync_bootstrap').timeout(_pullTimeout);
      return Success(_parseBootstrap(raw as Map<String, dynamic>));
    } on AuthException {
      return const Error(SyncAuthRequired());
    } on TimeoutException {
      return const Error(SyncTimeout());
    } catch (e) {
      return Error(SyncServerFailure('$e', retryable: true));
    }
  }

  @override
  Future<Result<Map<String, int>>> head(List<String> scopes) async {
    try {
      final raw = await _client
          .rpc('sync_head', params: {'p_scopes': scopes})
          .timeout(const Duration(seconds: 10));
      final map = Map<String, dynamic>.from(raw as Map);
      return Success({
        for (final e in map.entries)
          if (e.value is num) e.key: (e.value as num).toInt(),
      });
    } on AuthException {
      return const Error(SyncAuthRequired());
    } on TimeoutException {
      return const Error(SyncTimeout());
    } catch (e) {
      return Error(SyncServerFailure('$e', retryable: true));
    }
  }

  @override
  Future<Result<SyncPullPage>> pull({
    required String scope,
    required int since,
    int limit = 500,
  }) async {
    try {
      final raw = await _client
          .rpc('sync_pull', params: {
            'p_scope': scope,
            'p_since': since,
            'p_limit': limit,
          })
          .timeout(_pullTimeout);
      return Success(_parsePullPage(raw as Map<String, dynamic>));
    } on AuthException {
      return const Error(SyncAuthRequired());
    } on TimeoutException {
      return const Error(SyncTimeout());
    } catch (e) {
      return Error(SyncServerFailure('$e', retryable: true));
    }
  }

  @override
  Future<Result<SyncPushResponse>> push(List<SyncPushOp> ops) async {
    try {
      final payload = ops
          .map(
            (o) => {
              'op_id': o.opId,
              'table': o.table,
              'row_id': o.rowId,
              'op': o.op,
              'payload': o.payload,
              'client_created_at': o.clientCreatedAt?.toIso8601String(),
            },
          )
          .toList();
      final raw = await _client
          .rpc('sync_push', params: {'p_ops': payload})
          .timeout(_pushTimeout);
      return Success(_parsePushResponse(raw as Map<String, dynamic>));
    } on AuthException {
      return const Error(SyncAuthRequired());
    } on TimeoutException {
      return const Error(SyncTimeout());
    } catch (e) {
      return Error(SyncServerFailure('$e', retryable: true));
    }
  }

  SyncBootstrapData _parseBootstrap(Map<String, dynamic> raw) {
    final headsRaw = Map<String, dynamic>.from(raw['heads'] as Map? ?? {});
    return SyncBootstrapData(
      memberships: (raw['memberships'] as List? ?? [])
          .cast<Map<String, dynamic>>(),
      farms: (raw['farms'] as List? ?? []).cast<Map<String, dynamic>>(),
      heads: {
        for (final e in headsRaw.entries) e.key: (e.value as num).toInt(),
      },
      epoch: (raw['epoch'] as num?)?.toInt() ?? 1,
    );
  }

  SyncPullPage _parsePullPage(Map<String, dynamic> raw) {
    final rows = (raw['rows'] as List? ?? [])
        .cast<Map<String, dynamic>>()
        .map(
          (r) => SyncPullRow(
            table: r['table'] as String,
            serverVersion: (r['server_version'] as num).toInt(),
            row: Map<String, dynamic>.from(r['row'] as Map),
          ),
        )
        .toList();
    return SyncPullPage(
      rows: rows,
      nextCursor: (raw['next_cursor'] as num?)?.toInt() ?? 0,
      hasMore: raw['has_more'] as bool? ?? false,
      epoch: (raw['epoch'] as num?)?.toInt() ?? 1,
    );
  }

  SyncPushResponse _parsePushResponse(Map<String, dynamic> raw) {
    if (raw.containsKey('error')) {
      throw SyncRejected(raw['error'] as String? ?? 'rejected');
    }
    final results = (raw['results'] as List? ?? [])
        .cast<Map<String, dynamic>>()
        .map(
          (r) => SyncPushOpResult(
            opId: r['op_id'] as String,
            status: r['status'] as String,
            serverVersion: (r['server_version'] as num?)?.toInt(),
            row: r['row'] == null
                ? null
                : Map<String, dynamic>.from(r['row'] as Map),
            errorCode: r['error_code'] as String?,
            retryable: r['retryable'] as bool? ?? false,
          ),
        )
        .toList();
    return SyncPushResponse(
      results: results,
      epoch: (raw['epoch'] as num?)?.toInt() ?? 1,
    );
  }
}
