import '../../core/error/result.dart';

class SyncPushOp {
  const SyncPushOp({
    required this.opId,
    required this.tableName,
    required this.rowId,
    required this.op,
    required this.payload,
  });

  final String opId;
  final String tableName;
  final String rowId;
  final String op;
  final Map<String, dynamic> payload;
}

class SyncPushResult {
  const SyncPushResult({required this.acknowledgedOpIds});

  final List<String> acknowledgedOpIds;
}

class SyncPullRow {
  const SyncPullRow({
    required this.tableName,
    required this.rowId,
    required this.serverVersion,
    required this.payload,
    required this.deleted,
  });

  final String tableName;
  final String rowId;
  final int serverVersion;
  final Map<String, dynamic> payload;
  final bool deleted;
}

class SyncPullPage {
  const SyncPullPage({
    required this.rows,
    required this.hasMore,
  });

  final List<SyncPullRow> rows;
  final bool hasMore;
}

abstract class RemoteSyncApi {
  Future<Result<SyncPushResult>> push(List<SyncPushOp> ops);

  Future<Result<SyncPullPage>> pull({
    required String tableName,
    required int cursor,
    required int pageSize,
  });

  Future<Result<bool>> ping();
}
