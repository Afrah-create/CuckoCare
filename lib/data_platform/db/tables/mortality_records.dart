import 'package:drift/drift.dart';

/// Loss records (died, culled, missing, other). Mutable: farmers can fix typos.
@DataClassName('MortalityRecordRow')
@TableIndex(name: 'mortality_batch_occurred_idx', columns: {#batchId, #occurredOn})
class MortalityRecords extends Table {
  TextColumn get id => text()();
  TextColumn get farmId => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get serverVersion => integer().nullable()();

  TextColumn get batchId => text()();
  IntColumn get count => integer()();
  TextColumn get kind => text().withDefault(const Constant('died'))();
  TextColumn get suspectedCause => text().nullable()();
  DateTimeColumn get occurredOn => dateTime()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get editedAt => dateTime().nullable()();
  TextColumn get deletedGroupId => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
