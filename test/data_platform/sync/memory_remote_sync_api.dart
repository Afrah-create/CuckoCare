import 'package:cucocare/core/error/result.dart';
import 'package:cucocare/data_platform/sync/remote_sync_api.dart';
import 'package:cucocare/core/error/failure.dart';

/// In-memory remote for tests — mirrors scope-based sync semantics.
class MemoryRemoteSyncApi implements RemoteSyncApi {
  MemoryRemoteSyncApi({this.online = true});

  bool online;
  int epoch = 1;

  final Map<String, int> heads = {'reference': 0};
  final Map<String, List<SyncPullRow>> streams = {};
  final Map<String, SyncPushOpResult> applied = {};

  @override
  Future<Result<bool>> ping() async =>
      online ? const Success(true) : const Error(SyncOffline());

  @override
  Future<Result<SyncBootstrapData>> bootstrap() async {
    if (!online) {
      return const Error(SyncOffline());
    }
    return Success(
      SyncBootstrapData(
        memberships: const [],
        farms: const [],
        heads: Map.from(heads),
        epoch: epoch,
      ),
    );
  }

  @override
  Future<Result<Map<String, int>>> head(List<String> scopes) async {
    if (!online) {
      return const Error(SyncOffline());
    }
    return Success({
      for (final s in scopes) s: heads[s] ?? 0,
      'epoch': epoch,
    });
  }

  @override
  Future<Result<SyncPullPage>> pull({
    required String scope,
    required int since,
    int limit = 500,
  }) async {
    if (!online) {
      return const Error(SyncOffline());
    }
    final all = (streams[scope] ?? [])
        .where((r) => r.serverVersion > since)
        .toList()
      ..sort((a, b) => a.serverVersion.compareTo(b.serverVersion));
    final slice = all.take(limit).toList();
    final hasMore = all.length > limit;
    final next = slice.isEmpty ? since : slice.last.serverVersion;
    return Success(
      SyncPullPage(
        rows: slice,
        nextCursor: next,
        hasMore: hasMore,
        epoch: epoch,
      ),
    );
  }

  @override
  Future<Result<SyncPushResponse>> push(List<SyncPushOp> ops) async {
    if (!online) {
      return const Error(SyncOffline());
    }
    final results = <SyncPushOpResult>[];
    for (final op in ops) {
      if (applied.containsKey(op.opId)) {
        results.add(applied[op.opId]!);
        continue;
      }
      final scope = op.table.startsWith('programme') ? 'reference' : op.payload['farm_id'] as String;
      heads[scope] = (heads[scope] ?? 0) + 1;
      final ver = heads[scope]!;
      final row = {
        ...op.payload,
        'server_version': ver,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      };
      final result = SyncPushOpResult(
        opId: op.opId,
        status: 'applied',
        serverVersion: ver,
        row: row,
      );
      applied[op.opId] = result;
      streams.putIfAbsent(scope, () => []).add(
            SyncPullRow(
              table: op.table,
              serverVersion: ver,
              row: row,
            ),
          );
      results.add(result);
    }
    return Success(SyncPushResponse(results: results, epoch: epoch));
  }
}
