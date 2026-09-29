import 'package:drift/drift.dart';

@DataClassName('EntitlementRow')
class Entitlements extends Table {
  TextColumn get id => text()();
  TextColumn get farmId => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get serverVersion => integer().nullable()();

  TextColumn get plan => text()();
  TextColumn get status => text()();
  DateTimeColumn get validUntil => dateTime().nullable()();
  DateTimeColumn get lastVerifiedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
