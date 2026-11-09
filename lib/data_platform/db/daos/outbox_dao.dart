import 'package:drift/drift.dart';

import '../../../core/utils/uuid_v7.dart';
import '../app_database.dart';
import '../tables/outbox.dart';

part 'outbox_dao.g.dart';

@DriftAccessor(tables: [Outbox])
class OutboxDao extends DatabaseAccessor<AppDatabase> with _$OutboxDaoMixin {
  OutboxDao(super.db);

  static const leaseDuration = Duration(minutes: 5);

  Future<List<OutboxRow>> claimBatch({int limit = 100}) async {
    final now = DateTime.now().toUtc();
    final leaseUntil = now.add(leaseDuration);

    await (update(outbox)
          ..where(
            (t) =>
                t.state.equals('in_flight') &
                t.leaseUntil.isSmallerThanValue(now),
          ))
        .write(
      const OutboxCompanion(
        state: Value('pending'),
        leaseUntil: Value(null),
      ),
    );

    final rows = await (select(outbox)
          ..where(
            (t) =>
                t.state.equals('pending') &
                (t.nextAttemptAt.isNull() |
                    t.nextAttemptAt.isSmallerOrEqualValue(now)),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)])
          ..limit(limit))
        .get();

    for (final row in rows) {
      await (update(outbox)..where((t) => t.opId.equals(row.opId))).write(
        OutboxCompanion(
          state: const Value('in_flight'),
          leaseUntil: Value(leaseUntil),
        ),
      );
    }
    return rows;
  }

  Future<int> pendingCount() => _countWhere(
        (t) =>
            t.state.equals('pending') |
            t.state.equals('in_flight') |
            t.state.equals('blocked'),
      );

  Future<int> failedCount() =>
      _countWhere((t) => t.state.equals('failed'));

  Future<int> _countWhere(Expression<bool> Function(Outbox tbl) where) async {
    final count = countAll();
    final query = selectOnly(outbox)
      ..addColumns([count])
      ..where(where(outbox));
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  Future<void> markApplied(String opId) {
    return (delete(outbox)..where((t) => t.opId.equals(opId))).go();
  }

  /// New op_id, same payload. Used when the server acked 'applied' without a
  /// row (poisoned duplicate in sync_ops_applied).
  Future<void> reissue(String opId) async {
    final row = await (select(outbox)..where((t) => t.opId.equals(opId)))
        .getSingleOrNull();
    if (row == null) {
      return;
    }
    await (delete(outbox)..where((t) => t.opId.equals(opId))).go();
    await into(outbox).insert(
      OutboxCompanion.insert(
        opId: newId(),
        targetTable: row.targetTable,
        rowId: row.rowId,
        op: row.op,
        payload: row.payload,
        createdAt: DateTime.now().toUtc(),
        state: const Value('pending'),
        nextAttemptAt: Value(
          DateTime.now().toUtc().add(const Duration(seconds: 30)),
        ),
      ),
    );
  }

  Future<void> markFailed({
    required String opId,
    required String errorCode,
    required bool retryable,
    String? message,
  }) {
    return (update(outbox)..where((t) => t.opId.equals(opId))).write(
      OutboxCompanion(
        state: Value(retryable ? 'pending' : 'failed'),
        retryable: Value(retryable),
        errorCode: Value(errorCode),
        lastError: Value(message),
        leaseUntil: const Value(null),
        nextAttemptAt: retryable
            ? Value(DateTime.now().toUtc().add(const Duration(seconds: 30)))
            : const Value(null),
      ),
    );
  }

  Future<void> discard(String opId) {
    return (delete(outbox)..where((t) => t.opId.equals(opId))).go();
  }

  Future<void> retryFailed(String opId) {
    return (update(outbox)..where((t) => t.opId.equals(opId))).write(
      const OutboxCompanion(
        state: Value('pending'),
        errorCode: Value(null),
        lastError: Value(null),
        nextAttemptAt: Value(null),
      ),
    );
  }

  Future<List<OutboxRow>> failedOps({int limit = 50}) {
    return (select(outbox)
          ..where((t) => t.state.equals('failed'))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(limit))
        .get();
  }

  Future<void> deleteAllRows() => delete(outbox).go();
}
