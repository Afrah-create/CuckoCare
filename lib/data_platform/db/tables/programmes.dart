import 'package:drift/drift.dart';

@DataClassName('ProgrammeRow')
class Programmes extends Table {
  TextColumn get id => text()();
  TextColumn get farmId => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get serverVersion => integer().nullable()();

  TextColumn get name => text()();
  IntColumn get version => integer()();
  TextColumn get birdTypesJson => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
