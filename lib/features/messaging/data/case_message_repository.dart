import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';

import '../../../core/time/clock.dart';
import '../../../core/utils/uuid_v7.dart';
import '../../../data_platform/db/app_database.dart';
import '../../../data_platform/db/synced_write.dart';
import '../domain/case_thread.dart';
import '../domain/link_quality.dart';
import '../domain/media_policy.dart';
import '../domain/message_delivery_state.dart';
import '../domain/message_metrics.dart';
import '../domain/messaging_rules.dart';
import 'case_message_synced_table.dart';
import 'case_photo_compressor.dart';

typedef VetSendFn = Future<Map<String, dynamic>> Function({
  required String id,
  required String requestId,
  required String kind,
  required String? body,
  required DateTime clientCreatedAt,
});

typedef VetMarkReadFn = Future<void> Function({
  required String requestId,
  required String messageId,
});

class CaseMessageRepository {
  CaseMessageRepository({
    required AppDatabase db,
    required SyncedWrite write,
    required Clock clock,
    required String Function() currentUserId,
    required Future<String?> Function() farmRole,
    required bool Function() isVet,
    this.vetSend,
    this.vetMarkRead,
  })  : _db = db,
        _write = write,
        _clock = clock,
        _userId = currentUserId,
        _farmRole = farmRole,
        _isVet = isVet;

  final AppDatabase _db;
  final SyncedWrite _write;
  final Clock _clock;
  final String Function() _userId;
  final Future<String?> Function() _farmRole;
  final bool Function() _isVet;
  final VetSendFn? vetSend;
  final VetMarkReadFn? vetMarkRead;
  final _mapper = CaseMessageSyncedTable();
  final _rules = const MessagingRules();
  final _metrics = const MessageMetrics();

  Future<void> sendText({
    required String requestId,
    required String farmId,
    required String requestStatus,
    required String body,
  }) async {
    final error = _rules.validateText(body);
    if (error != null) {
      throw ArgumentError(error);
    }
    final role = await _farmRole() ?? 'viewer';
    final vet = _isVet();
    if (!_rules.canSend(
      requestStatus: requestStatus,
      farmRole: role,
      isAssignedVet: vet,
      requestDeleted: false,
    )) {
      throw StateError(_rules.composerDisabledReason(
        requestStatus: requestStatus,
        isViewer: role == 'viewer' && !vet,
      ));
    }
    final now = _clock.now();
    final id = newId();
    final trimmed = body.trim();
    final row = CaseMessageRow(
      id: id,
      farmId: farmId,
      requestId: requestId,
      createdAt: now,
      updatedAt: now,
      deletedAt: null,
      serverVersion: null,
      senderUserId: _userId(),
      senderRole: vet ? 'vet' : 'farmer',
      kind: 'text',
      body: trimmed,
      clientCreatedAt: now,
      localFailReason: null,
    );
    if (vet) {
      await _db.into(_db.caseMessages).insert(row);
      try {
        final ack = await vetSend?.call(
          id: id,
          requestId: requestId,
          kind: 'text',
          body: trimmed,
          clientCreatedAt: now,
        );
        if (ack != null && ack['server_version'] != null) {
          await (_db.update(_db.caseMessages)..where((t) => t.id.equals(id)))
              .write(
            CaseMessagesCompanion(
              serverVersion: Value(syncJsonIntSafe(ack['server_version'])),
            ),
          );
        }
      } catch (_) {
        await (_db.update(_db.caseMessages)..where((t) => t.id.equals(id)))
            .write(
          const CaseMessagesCompanion(
            localFailReason: Value('Could not send. Saved on this phone.'),
          ),
        );
      }
      return;
    }
    await _write.writeSynced(
      writeRow: () => _db.into(_db.caseMessages).insert(row),
      table: _mapper.tableName,
      rowId: id,
      op: 'upsert',
      payload: _mapper.toPayload(row),
    );
  }

  Future<void> sendPhotos({
    required String requestId,
    required String farmId,
    required String requestStatus,
    required List<String> localPaths,
    required LinkQualityLevel quality,
    required bool metered,
    required bool dataSaver,
    String? caption,
    bool userForced = false,
  }) async {
    if (localPaths.isEmpty ||
        localPaths.length > MessagingRules.maxPhotosPerMessage) {
      throw ArgumentError('photo_count');
    }
    final role = await _farmRole() ?? 'viewer';
    final vet = _isVet();
    if (!_rules.canSend(
      requestStatus: requestStatus,
      farmRole: role,
      isAssignedVet: vet,
      requestDeleted: false,
    )) {
      throw StateError(_rules.composerDisabledReason(
        requestStatus: requestStatus,
        isViewer: role == 'viewer' && !vet,
      ));
    }
    final now = _clock.now();
    final id = newId();
    final decision = const MediaPolicy().decide(
      quality: quality,
      metered: metered,
      dataSaver: dataSaver,
      sizeBytes: 0,
      userForced: userForced,
    );
    final compressor = const CasePhotoCompressor();
    final thumbs = <({String path, CompressedPhoto photo, String attachmentId})>[];
    for (final path in localPaths) {
      final photo = compressor.compressFile(File(path), decision);
      thumbs.add((
        path: path,
        photo: photo,
        attachmentId: newId(),
      ));
    }
    final row = CaseMessageRow(
      id: id,
      farmId: farmId,
      requestId: requestId,
      createdAt: now,
      updatedAt: now,
      deletedAt: null,
      serverVersion: null,
      senderUserId: _userId(),
      senderRole: vet ? 'vet' : 'farmer',
      kind: 'photo',
      body: caption?.trim().isEmpty == true ? null : caption?.trim(),
      clientCreatedAt: now,
      localFailReason: null,
    );
    final ops = <SyncedWriteOp>[
      SyncedWriteOp(
        writeRow: () async {
          await _db.into(_db.caseMessages).insert(row);
          for (final item in thumbs) {
            await _db.into(_db.caseMessageAttachments).insert(
                  CaseMessageAttachmentRow(
                    id: item.attachmentId,
                    farmId: farmId,
                    requestId: requestId,
                    messageId: id,
                    createdAt: now,
                    updatedAt: now,
                    deletedAt: null,
                    serverVersion: null,
                    objectKey:
                        '$farmId/requests/$requestId/messages/$id/${item.attachmentId}.jpg',
                    mime: 'image/jpeg',
                    bytes: item.photo.bytes.length,
                    width: item.photo.width,
                    height: item.photo.height,
                    thumbB64: item.photo.thumbB64,
                    status: 'pending',
                  ),
                );
            await _db.into(_db.mediaUploadJobs).insert(
                  MediaUploadJobRow(
                    id: newId(),
                    attachmentId: item.attachmentId,
                    requestId: requestId,
                    localPath: item.path,
                    state: decision.sendNow ? 'queued' : 'queued',
                    attempts: 0,
                    bytesSent: 0,
                    nextAttemptAt: decision.sendNow ? now : null,
                    userForced: userForced,
                    createdAt: now,
                  ),
                );
          }
        },
        table: _mapper.tableName,
        rowId: id,
        op: 'upsert',
        payload: _mapper.toPayload(row),
      ),
    ];
    final attachMapper = CaseMessageAttachmentSyncedTable();
    for (final item in thumbs) {
      ops.add(
        SyncedWriteOp(
          writeRow: () async {},
          table: attachMapper.tableName,
          rowId: item.attachmentId,
          op: 'upsert',
          payload: attachMapper.toPayload(
            CaseMessageAttachmentRow(
              id: item.attachmentId,
              farmId: farmId,
              requestId: requestId,
              messageId: id,
              createdAt: now,
              updatedAt: now,
              deletedAt: null,
              serverVersion: null,
              objectKey:
                  '$farmId/requests/$requestId/messages/$id/${item.attachmentId}.jpg',
              mime: 'image/jpeg',
              bytes: item.photo.bytes.length,
              width: item.photo.width,
              height: item.photo.height,
              thumbB64: item.photo.thumbB64,
              status: 'pending',
            ),
          ),
        ),
      );
    }
    if (vet) {
      await _db.transaction(() async {
        for (final op in ops) {
          await op.writeRow();
        }
      });
      await vetSend?.call(
        id: id,
        requestId: requestId,
        kind: 'photo',
        body: row.body,
        clientCreatedAt: now,
      );
      return;
    }
    await _write.writeSyncedMany(ops);
  }

  /// Re-enqueue local farmer messages whose outbox payload omitted `farm_id`.
  /// Those ops were rejected by `sync_push` 0028 and otherwise stay queued.
  Future<void> repairFarmerOutboxPayloads(String requestId) async {
    if (_isVet()) {
      return;
    }
    final rows = await (_db.select(_db.caseMessages)
          ..where((t) => t.requestId.equals(requestId)))
        .get();
    for (final row in rows) {
      if (row.serverVersion != null) {
        continue;
      }
      final ops = await (_db.select(_db.outbox)
            ..where(
              (o) =>
                  o.targetTable.equals('case_messages') &
                  o.rowId.equals(row.id),
            ))
          .get();
      if (ops.isEmpty) {
        await retryFailed(row.id);
        continue;
      }
      var needsRepair = false;
      for (final op in ops) {
        try {
          final payload = jsonDecode(op.payload) as Map<String, dynamic>;
          if (payload['farm_id'] == null || op.state == 'failed') {
            needsRepair = true;
          }
        } catch (_) {
          needsRepair = true;
        }
      }
      if (needsRepair) {
        await retryFailed(row.id);
      }
    }
  }

  Future<void> retryFailed(String messageId) async {
    await (_db.update(_db.caseMessages)..where((t) => t.id.equals(messageId)))
        .write(const CaseMessagesCompanion(localFailReason: Value(null)));
    final row = await (_db.select(_db.caseMessages)
          ..where((t) => t.id.equals(messageId)))
        .getSingleOrNull();
    if (row == null) {
      return;
    }
    // Mint a new op_id. Terminal 42501 results are stored in
    // sync_ops_applied, so replaying the same id stays rejected forever.
    await (_db.delete(_db.outbox)
          ..where(
            (o) =>
                o.targetTable.equals('case_messages') &
                o.rowId.equals(messageId),
          ))
        .go();
    await _write.writeSynced(
      writeRow: () async {},
      table: _mapper.tableName,
      rowId: messageId,
      op: 'upsert',
      payload: _mapper.toPayload(row),
    );
  }

  String? copyFailedText(CaseThreadMessage message) => message.body;

  Future<void> markRead({
    required String requestId,
    required String farmId,
    required String messageId,
  }) async {
    final now = _clock.now();
    final uid = _userId();
    final existing = await (_db.select(_db.caseReadStates)
          ..where((t) => t.requestId.equals(requestId) & t.userId.equals(uid)))
        .getSingleOrNull();
    if (existing != null && !now.isAfter(existing.lastReadAt)) {
      return;
    }
    final row = CaseReadStateRow(
      requestId: requestId,
      userId: uid,
      farmId: farmId,
      lastReadAt: now,
      lastReadMessageId: messageId,
      muted: existing?.muted ?? false,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
      deletedAt: null,
      serverVersion: existing?.serverVersion,
    );
    if (_isVet()) {
      await _db.into(_db.caseReadStates).insertOnConflictUpdate(row);
      await vetMarkRead?.call(requestId: requestId, messageId: messageId);
      return;
    }
    await _write.writeSynced(
      writeRow: () =>
          _db.into(_db.caseReadStates).insertOnConflictUpdate(row),
      table: 'case_read_state',
      rowId: '$requestId:$uid',
      op: 'upsert',
      payload: CaseReadStateSyncedTable().toPayload(row),
    );
  }

  Future<void> setMuted({
    required String requestId,
    required String farmId,
    required bool muted,
  }) async {
    final uid = _userId();
    final now = _clock.now();
    final existing = await (_db.select(_db.caseReadStates)
          ..where((t) => t.requestId.equals(requestId) & t.userId.equals(uid)))
        .getSingleOrNull();
    final row = CaseReadStateRow(
      requestId: requestId,
      userId: uid,
      farmId: farmId,
      lastReadAt: existing?.lastReadAt ?? now,
      lastReadMessageId: existing?.lastReadMessageId,
      muted: muted,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
      deletedAt: null,
      serverVersion: existing?.serverVersion,
    );
    await _write.writeSynced(
      writeRow: () =>
          _db.into(_db.caseReadStates).insertOnConflictUpdate(row),
      table: 'case_read_state',
      rowId: '$requestId:$uid',
      op: 'upsert',
      payload: CaseReadStateSyncedTable().toPayload(row),
    );
  }

  Stream<List<CaseThreadMessage>> watchThread(String requestId) {
    return _db.select(_db.caseMessages).watch().asyncMap((_) async {
      return loadThread(requestId);
    });
  }

  Future<List<CaseThreadMessage>> loadThread(String requestId) async {
    final uid = _userId();
    final rows = await (_db.select(_db.caseMessages)
          ..where(
            (t) => t.requestId.equals(requestId) & t.deletedAt.isNull(),
          ))
        .get();
    final attachments = await (_db.select(_db.caseMessageAttachments)
          ..where((t) => t.requestId.equals(requestId)))
        .get();
    final byMessage = <String, List<CaseMessageAttachmentRow>>{};
    for (final a in attachments) {
      byMessage.putIfAbsent(a.messageId, () => []).add(a);
    }
    final outbox = await (_db.select(_db.outbox)
          ..where((o) => o.targetTable.equals('case_messages')))
        .get();
    final outboxByRow = {for (final o in outbox) o.rowId: o};
    final otherCursor = await _otherCursor(requestId, uid);
    final mapped = [
      for (final row in rows)
        CaseThreadMessage(
          id: row.id,
          requestId: row.requestId,
          senderUserId: row.senderUserId,
          senderRole: row.senderRole,
          kind: row.kind,
          body: row.body,
          clientCreatedAt: row.clientCreatedAt,
          createdAt: row.createdAt,
          serverVersion: row.serverVersion,
          delivery: MessageDeliveryState.derive(
            inOutbox: outboxByRow[row.id]?.state == 'pending',
            inFlight: outboxByRow[row.id]?.state == 'in_flight',
            failed: row.localFailReason != null ||
                outboxByRow[row.id]?.state == 'failed',
            failReason: row.localFailReason ??
                _rules.mapSyncFailure(outboxByRow[row.id]?.errorCode),
            hasServerVersion: row.serverVersion != null,
            seenByOther: otherCursor != null &&
                row.serverVersion != null &&
                !row.createdAt.isAfter(otherCursor) &&
                row.senderUserId == uid,
          ),
          attachments: [
            for (final a in byMessage[row.id] ?? const <CaseMessageAttachmentRow>[])
              CaseThreadAttachment(
                id: a.id,
                objectKey: a.objectKey,
                status: a.status,
                bytes: a.bytes,
                thumbB64: a.thumbB64,
                subState: a.status == 'uploaded'
                    ? AttachmentSubState.uploaded
                    : AttachmentSubState.waitingForSignal,
              ),
          ],
        ),
    ];
    return CaseThread.order(mapped);
  }

  Stream<int> watchUnreadForRequest(String requestId) {
    return _db.select(_db.caseMessages).watch().asyncMap((_) async {
      final messages = await loadThread(requestId);
      final uid = _userId();
      final mine = await (_db.select(_db.caseReadStates)
            ..where(
              (t) => t.requestId.equals(requestId) & t.userId.equals(uid),
            ))
          .getSingleOrNull();
      return _metrics.unreadForCase(
        messages: messages,
        myUserId: uid,
        lastReadAt: mine?.lastReadAt,
      );
    });
  }

  Stream<int> watchFarmUnread(String farmId) {
    return _db.select(_db.caseMessages).watch().asyncMap((_) async {
      final uid = _userId();
      final messages = await (_db.select(_db.caseMessages)
            ..where((t) => t.farmId.equals(farmId) & t.deletedAt.isNull()))
          .get();
      final reads = await (_db.select(_db.caseReadStates)
            ..where((t) => t.userId.equals(uid)))
          .get();
      final lastRead = {for (final r in reads) r.requestId: r.lastReadAt};
      final grouped = _metrics.grouped(
        messages: [
          for (final row in messages)
            CaseThreadMessage(
              id: row.id,
              requestId: row.requestId,
              senderUserId: row.senderUserId,
              senderRole: row.senderRole,
              kind: row.kind,
              body: row.body,
              clientCreatedAt: row.clientCreatedAt,
              createdAt: row.createdAt,
              serverVersion: row.serverVersion,
              delivery: const MessageDeliveryState(MessageDeliveryKind.sent),
            ),
        ],
        myUserId: uid,
        lastReadByRequest: lastRead,
      );
      return _metrics.totalUnread(grouped);
    });
  }

  Stream<int> watchAllUnread() {
    return _db.select(_db.caseMessages).watch().asyncMap((_) async {
      final uid = _userId();
      final messages = await (_db.select(_db.caseMessages)
            ..where((t) => t.deletedAt.isNull()))
          .get();
      final reads = await (_db.select(_db.caseReadStates)
            ..where((t) => t.userId.equals(uid)))
          .get();
      final lastRead = {for (final r in reads) r.requestId: r.lastReadAt};
      final grouped = _metrics.grouped(
        messages: [
          for (final row in messages)
            CaseThreadMessage(
              id: row.id,
              requestId: row.requestId,
              senderUserId: row.senderUserId,
              senderRole: row.senderRole,
              kind: row.kind,
              body: row.body,
              clientCreatedAt: row.clientCreatedAt,
              createdAt: row.createdAt,
              serverVersion: row.serverVersion,
              delivery: const MessageDeliveryState(MessageDeliveryKind.sent),
            ),
        ],
        myUserId: uid,
        lastReadByRequest: lastRead,
      );
      return _metrics.totalUnread(grouped);
    });
  }

  Stream<UnreadThreadHint?> watchNewestUnreadHint() {
    return _db.select(_db.caseMessages).watch().asyncMap((_) async {
      final uid = _userId();
      final messages = await (_db.select(_db.caseMessages)
            ..where((t) => t.deletedAt.isNull()))
          .get();
      final reads = await (_db.select(_db.caseReadStates)
            ..where((t) => t.userId.equals(uid)))
          .get();
      final lastRead = {for (final r in reads) r.requestId: r.lastReadAt};
      final grouped = _metrics.grouped(
        messages: [
          for (final row in messages)
            CaseThreadMessage(
              id: row.id,
              requestId: row.requestId,
              senderUserId: row.senderUserId,
              senderRole: row.senderRole,
              kind: row.kind,
              body: row.body,
              clientCreatedAt: row.clientCreatedAt,
              createdAt: row.createdAt,
              serverVersion: row.serverVersion,
              delivery: const MessageDeliveryState(MessageDeliveryKind.sent),
            ),
        ],
        myUserId: uid,
        lastReadByRequest: lastRead,
      );
      final unread = grouped.where((e) => e.unread > 0).toList();
      if (unread.isEmpty) return null;
      unread.sort((a, b) => b.unread.compareTo(a.unread));
      final top = unread.first;
      final request = await (_db.select(_db.vetAssistanceRequests)
            ..where((t) => t.id.equals(top.requestId)))
          .getSingleOrNull();
      return UnreadThreadHint(
        requestId: top.requestId,
        farmId: request?.farmId ?? '',
        status: request?.status ?? 'submitted',
        priority: request?.priority ?? 'normal',
        summary: request?.farmerNotes,
        unread: top.unread,
      );
    });
  }

  Future<DateTime?> _otherCursor(String requestId, String myUserId) async {
    final rows = await (_db.select(_db.caseReadStates)
          ..where(
            (t) => t.requestId.equals(requestId) & t.userId.equals(myUserId).not(),
          ))
        .get();
    if (rows.isEmpty) return null;
    rows.sort((a, b) => b.lastReadAt.compareTo(a.lastReadAt));
    return rows.first.lastReadAt;
  }
}

int? syncJsonIntSafe(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value');
}
