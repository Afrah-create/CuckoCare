import '../../../data_platform/db/app_database.dart';
import '../../../data_platform/sync/sync_json.dart';
import '../../../data_platform/sync/synced_table.dart';

class CaseMessageSyncedTable implements SyncedTable<CaseMessageRow> {
  @override
  String get tableName => 'case_messages';

  @override
  SyncTableKind get kind => SyncTableKind.appendOnly;

  @override
  String scopeForRow(CaseMessageRow row) => row.farmId;

  @override
  CaseMessageRow fromRemote(Map<String, dynamic> json) {
    return CaseMessageRow(
      id: json['id'] as String,
      farmId: json['farm_id'] as String,
      requestId: json['request_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
      serverVersion: syncJsonInt(json['server_version']),
      senderUserId: json['sender_user_id'] as String?,
      senderRole: json['sender_role'] as String,
      kind: json['kind'] as String,
      body: json['body'] as String?,
      clientCreatedAt: DateTime.parse(
        json['client_created_at'] as String? ?? json['created_at'] as String,
      ),
      localFailReason: null,
    );
  }

  @override
  Map<String, dynamic> toPayload(CaseMessageRow row) {
    return {
      'id': row.id,
      'farm_id': row.farmId,
      'request_id': row.requestId,
      'kind': row.kind,
      if (row.body != null) 'body': row.body,
      'client_created_at': row.clientCreatedAt.toIso8601String(),
    };
  }
}

class CaseMessageAttachmentSyncedTable
    implements SyncedTable<CaseMessageAttachmentRow> {
  @override
  String get tableName => 'case_message_attachments';

  @override
  SyncTableKind get kind => SyncTableKind.mutable;

  @override
  String scopeForRow(CaseMessageAttachmentRow row) => row.farmId;

  @override
  CaseMessageAttachmentRow fromRemote(Map<String, dynamic> json) {
    return CaseMessageAttachmentRow(
      id: json['id'] as String,
      farmId: json['farm_id'] as String,
      requestId: json['request_id'] as String,
      messageId: json['message_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
      serverVersion: syncJsonInt(json['server_version']),
      objectKey: json['object_key'] as String? ?? '',
      mime: json['mime'] as String? ?? 'image/jpeg',
      bytes: syncJsonInt(json['bytes']),
      width: syncJsonInt(json['width']),
      height: syncJsonInt(json['height']),
      thumbB64: json['thumb_b64'] as String?,
      status: json['status'] as String? ?? 'pending',
    );
  }

  @override
  Map<String, dynamic> toPayload(CaseMessageAttachmentRow row) {
    return {
      'id': row.id,
      'farm_id': row.farmId,
      'request_id': row.requestId,
      'message_id': row.messageId,
      'object_key': row.objectKey,
      'mime': row.mime,
      if (row.bytes != null) 'bytes': row.bytes,
      if (row.width != null) 'width': row.width,
      if (row.height != null) 'height': row.height,
      if (row.thumbB64 != null) 'thumb_b64': row.thumbB64,
      'status': row.status,
    };
  }
}

class CaseReadStateSyncedTable implements SyncedTable<CaseReadStateRow> {
  @override
  String get tableName => 'case_read_state';

  @override
  SyncTableKind get kind => SyncTableKind.mutable;

  @override
  String scopeForRow(CaseReadStateRow row) => row.farmId ?? '';

  @override
  CaseReadStateRow fromRemote(Map<String, dynamic> json) {
    return CaseReadStateRow(
      requestId: json['request_id'] as String,
      userId: json['user_id'] as String,
      farmId: json['farm_id'] as String?,
      lastReadAt: DateTime.parse(json['last_read_at'] as String),
      lastReadMessageId: json['last_read_message_id'] as String?,
      muted: syncJsonBool(json['muted']),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
      serverVersion: syncJsonInt(json['server_version']),
    );
  }

  @override
  Map<String, dynamic> toPayload(CaseReadStateRow row) {
    return {
      'request_id': row.requestId,
      'user_id': row.userId,
      if (row.farmId != null && row.farmId!.trim().isNotEmpty)
        'farm_id': row.farmId,
      'last_read_at': row.lastReadAt.toIso8601String(),
      if (row.lastReadMessageId != null &&
          row.lastReadMessageId!.trim().isNotEmpty)
        'last_read_message_id': row.lastReadMessageId,
      'muted': row.muted,
    };
  }
}
