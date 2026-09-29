import '../../core/error/result.dart';

class SyncPushOp {
  const SyncPushOp({
    required this.opId,
    required this.table,
    required this.rowId,
    required this.op,
    required this.payload,
    this.clientCreatedAt,
  });

  final String opId;
  final String table;
  final String rowId;
  final String op;
  final Map<String, dynamic> payload;
  final DateTime? clientCreatedAt;
}

class SyncPushOpResult {
  const SyncPushOpResult({
    required this.opId,
    required this.status,
    this.serverVersion,
    this.row,
    this.errorCode,
    this.retryable = false,
  });

  final String opId;
  final String status;
  final int? serverVersion;
  final Map<String, dynamic>? row;
  final String? errorCode;
  final bool retryable;
}

class SyncPushResponse {
  const SyncPushResponse({
    required this.results,
    required this.epoch,
  });

  final List<SyncPushOpResult> results;
  final int epoch;
}

class SyncPullRow {
  const SyncPullRow({
    required this.table,
    required this.serverVersion,
    required this.row,
  });

  final String table;
  final int serverVersion;
  final Map<String, dynamic> row;
}

class SyncPullPage {
  const SyncPullPage({
    required this.rows,
    required this.nextCursor,
    required this.hasMore,
    required this.epoch,
  });

  final List<SyncPullRow> rows;
  final int nextCursor;
  final bool hasMore;
  final int epoch;
}

class SyncBootstrapData {
  const SyncBootstrapData({
    required this.memberships,
    required this.farms,
    required this.heads,
    required this.epoch,
  });

  final List<Map<String, dynamic>> memberships;
  final List<Map<String, dynamic>> farms;
  final Map<String, int> heads;
  final int epoch;
}

abstract class RemoteSyncApi {
  Future<Result<SyncBootstrapData>> bootstrap();

  Future<Result<Map<String, int>>> head(List<String> scopes);

  Future<Result<SyncPullPage>> pull({
    required String scope,
    required int since,
    int limit = 500,
  });

  Future<Result<SyncPushResponse>> push(List<SyncPushOp> ops);

  /// Cheap reachability probe (sync_head on reference scope).
  Future<Result<bool>> ping();
}

typedef RemoteSyncFactory = RemoteSyncApi Function();
