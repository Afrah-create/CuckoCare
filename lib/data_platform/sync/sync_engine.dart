import '../../core/error/result.dart';

enum SyncPhase {
  idle,
  syncing,
  offline,
  error,
  authRequired,
  signedOutDemo,
}

class SyncStatus {
  const SyncStatus({
    required this.phase,
    required this.pendingOutboxCount,
    this.failedOutboxCount = 0,
    this.lastSyncedAt,
    this.message,
    this.hydrationProgress,
  });

  final SyncPhase phase;
  final int pendingOutboxCount;
  final int failedOutboxCount;
  final DateTime? lastSyncedAt;
  final String? message;
  final int? hydrationProgress;

  SyncStatus copyWith({
    SyncPhase? phase,
    int? pendingOutboxCount,
    int? failedOutboxCount,
    DateTime? lastSyncedAt,
    String? message,
    int? hydrationProgress,
  }) {
    return SyncStatus(
      phase: phase ?? this.phase,
      pendingOutboxCount: pendingOutboxCount ?? this.pendingOutboxCount,
      failedOutboxCount: failedOutboxCount ?? this.failedOutboxCount,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      message: message ?? this.message,
      hydrationProgress: hydrationProgress ?? this.hydrationProgress,
    );
  }
}

abstract class SyncEngine {
  Stream<SyncStatus> get status;

  Future<Result<void>> syncOnce({bool force = false});

  Future<void> fullResync();
}
