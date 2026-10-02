import 'package:drift/drift.dart';

@DataClassName('HealthRecordRow')
class HealthRecords extends Table {
  TextColumn get id => text()();
  TextColumn get farmId => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get serverVersion => integer().nullable()();

  TextColumn get batchId => text()();
  DateTimeColumn get occurredOn => dateTime()();
  TextColumn get summary => text()();
  TextColumn get notes => text().nullable()();
  IntColumn get affectedBirdCount => integer().nullable()();
  TextColumn get symptomsJson => text().withDefault(const Constant('[]'))();
  TextColumn get recordKind =>
      text().withDefault(const Constant('observation'))();
  TextColumn get photoObjectKeysJson =>
      text().withDefault(const Constant('[]'))();
  /// Local filesystem paths awaiting upload (not synced to server).
  TextColumn get pendingPhotoPathsJson =>
      text().withDefault(const Constant('[]'))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
