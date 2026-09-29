import 'package:drift/drift.dart';

@DataClassName('FarmMemberRow')
class FarmMembers extends Table {
  TextColumn get id => text()();
  TextColumn get farmId => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get serverVersion => integer().nullable()();

  TextColumn get userId => text()();
  TextColumn get role => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
