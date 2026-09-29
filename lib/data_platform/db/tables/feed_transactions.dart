import 'package:drift/drift.dart';

@DataClassName('FeedTransactionRow')
class FeedTransactions extends Table {
  TextColumn get id => text()();
  TextColumn get farmId => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get serverVersion => integer().nullable()();

  TextColumn get feedItemId => text()();
  TextColumn get batchId => text().nullable()();
  TextColumn get kind => text()();
  RealColumn get quantity => real()();
  RealColumn get unitCost => real().nullable()();
  DateTimeColumn get occurredOn => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
