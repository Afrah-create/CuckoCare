import 'package:drift/drift.dart';

@DataClassName('CaseMessageRow')
class CaseMessages extends Table {
  TextColumn get id => text()();
  TextColumn get farmId => text()();
  TextColumn get requestId => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get serverVersion => integer().nullable()();
  TextColumn get senderUserId => text().nullable()();
  TextColumn get senderRole => text()();
  TextColumn get kind => text()();
  TextColumn get body => text().nullable()();
  DateTimeColumn get clientCreatedAt => dateTime()();
  TextColumn get localFailReason => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('CaseMessageAttachmentRow')
class CaseMessageAttachments extends Table {
  TextColumn get id => text()();
  TextColumn get farmId => text()();
  TextColumn get requestId => text()();
  TextColumn get messageId => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get serverVersion => integer().nullable()();
  TextColumn get objectKey => text()();
  TextColumn get mime => text().withDefault(const Constant('image/jpeg'))();
  IntColumn get bytes => integer().nullable()();
  IntColumn get width => integer().nullable()();
  IntColumn get height => integer().nullable()();
  TextColumn get thumbB64 => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('pending'))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('CaseReadStateRow')
class CaseReadStates extends Table {
  TextColumn get requestId => text()();
  TextColumn get userId => text()();
  TextColumn get farmId => text().nullable()();
  DateTimeColumn get lastReadAt => dateTime()();
  TextColumn get lastReadMessageId => text().nullable()();
  BoolColumn get muted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get serverVersion => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {requestId, userId};
}

@DataClassName('MediaUploadJobRow')
class MediaUploadJobs extends Table {
  TextColumn get id => text()();
  TextColumn get attachmentId => text()();
  TextColumn get requestId => text()();
  TextColumn get localPath => text()();
  TextColumn get state => text().withDefault(const Constant('queued'))();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  IntColumn get bytesSent => integer().withDefault(const Constant(0))();
  DateTimeColumn get nextAttemptAt => dateTime().nullable()();
  BoolColumn get userForced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('MediaCacheRow')
class MediaCache extends Table {
  TextColumn get objectKey => text()();
  TextColumn get localPath => text()();
  IntColumn get bytes => integer()();
  DateTimeColumn get lastAccessAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {objectKey};
}

@DataClassName('PushRegistrationRow')
class PushRegistrations extends Table {
  TextColumn get tokenHash => text()();
  DateTimeColumn get registeredAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {tokenHash};
}
