import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/outbox.dart';

part 'outbox_dao.g.dart';

@DriftAccessor(tables: [Outbox])
class OutboxDao extends DatabaseAccessor<AppDatabase> with _$OutboxDaoMixin {
  OutboxDao(super.db);

  Future<List<OutboxRow>> pending({int limit = 50}) {
    return (select(outbox)
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)])
          ..limit(limit))
        .get();
  }

  Future<int> deleteOp(String opId) {
    return (delete(outbox)..where((t) => t.opId.equals(opId))).go();
  }

  Future<void> recordFailure(String opId, String error, int attempts) {
    return (update(outbox)..where((t) => t.opId.equals(opId))).write(
      OutboxCompanion(
        attempts: Value(attempts),
        lastError: Value(error),
      ),
    );
  }

  Future<int> pendingCount() async {
    final count = countAll();
    final query = selectOnly(outbox)..addColumns([count]);
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }
}
