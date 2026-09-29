import 'package:drift/drift.dart';

@DataClassName('FeedItemRow')
class FeedItems extends Table {
  TextColumn get id => text()();
  TextColumn get farmId => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get serverVersion => integer().nullable()();

  TextColumn get name => text()();
  TextColumn get feedType => text()();
  TextColumn get unit => text()();
  RealColumn get reorderLevel => real().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
