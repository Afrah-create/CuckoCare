import '../../core/error/result.dart';

enum SyncPhase { idle, syncing, offline, error }

class SyncStatus {
  const SyncStatus({
    required this.phase,
    required this.pendingOutboxCount,
    this.lastSyncedAt,
    this.message,
  });

  final SyncPhase phase;
  final int pendingOutboxCount;
  final DateTime? lastSyncedAt;
  final String? message;

  SyncStatus copyWith({
    SyncPhase? phase,
    int? pendingOutboxCount,
    DateTime? lastSyncedAt,
    String? message,
  }) {
    return SyncStatus(
      phase: phase ?? this.phase,
      pendingOutboxCount: pendingOutboxCount ?? this.pendingOutboxCount,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      message: message ?? this.message,
    );
  }
}

abstract class SyncEngine {
  Stream<SyncStatus> get status;

  Future<Result<void>> syncOnce({bool force = false});
}
