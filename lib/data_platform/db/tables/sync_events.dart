import 'package:drift/drift.dart';

@DataClassName('SyncEventRow')
class SyncEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get occurredAt => dateTime()();
  TextColumn get level => text()();
  TextColumn get message => text()();
}
