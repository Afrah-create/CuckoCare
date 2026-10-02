import 'package:drift/drift.dart';

@DataClassName('FarmRow')
class Farms extends Table {
  TextColumn get id => text()();
  TextColumn get farmId => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get serverVersion => integer().nullable()();

  TextColumn get name => text()();
  TextColumn get location => text().nullable()();
  TextColumn get district => text().nullable()();
  TextColumn get village => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get altPhone => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get profileCompletedAt => dateTime().nullable()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  RealColumn get locationAccuracyM => real().nullable()();
  DateTimeColumn get locationCapturedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
