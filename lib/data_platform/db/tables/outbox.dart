import 'package:drift/drift.dart';

@DataClassName('OutboxRow')
class Outbox extends Table {
  TextColumn get opId => text()();
  TextColumn get targetTable => text()();
  TextColumn get rowId => text()();
  TextColumn get op => text()();
  TextColumn get payload => text()();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
  TextColumn get state =>
      text().withDefault(const Constant('pending'))(); // pending|in_flight|failed|blocked
  DateTimeColumn get leaseUntil => dateTime().nullable()();
  BoolColumn get retryable => boolean().withDefault(const Constant(true))();
  TextColumn get errorCode => text().nullable()();
  DateTimeColumn get nextAttemptAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {opId};
}
