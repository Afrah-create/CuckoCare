import 'package:cucocare/core/error/failure.dart';
import 'package:cucocare/core/error/result.dart';
import 'package:cucocare/data_platform/sync/remote_sync_api.dart';

class FakeRemoteSyncApi implements RemoteSyncApi {
  FakeRemoteSyncApi({this.online = true, this.failNextPush = false});

  bool online;
  bool failNextPush;

  final pushedOps = <SyncPushOp>[];
  final acknowledged = <String>{};

  final Map<String, List<SyncPullRow>> pullData = {};
  final Map<String, int> cursors = {};

  @override
  Future<Result<bool>> ping() async => Success(online);

  @override
  Future<Result<SyncPushResult>> push(List<SyncPushOp> ops) async {
    if (!online) {
      return const Error(NetworkFailure());
    }
    if (failNextPush) {
      failNextPush = false;
      return const Error(SyncFailure('push failed'));
    }
    pushedOps.addAll(ops);
    for (final op in ops) {
      if (acknowledged.contains(op.opId)) {
        continue;
      }
      acknowledged.add(op.opId);
    }
    return Success(
      SyncPushResult(
        acknowledgedOpIds: ops.map((o) => o.opId).toList(),
      ),
    );
  }

  @override
  Future<Result<SyncPullPage>> pull({
    required String tableName,
    required int cursor,
    required int pageSize,
  }) async {
    if (!online) {
      return const Error(NetworkFailure());
    }
    final rows = (pullData[tableName] ?? [])
        .where((r) => r.serverVersion > cursor)
        .take(pageSize)
        .toList();
    final hasMore = (pullData[tableName] ?? [])
            .where((r) => r.serverVersion > cursor)
            .length >
        pageSize;
    return Success(SyncPullPage(rows: rows, hasMore: hasMore));
  }
}
