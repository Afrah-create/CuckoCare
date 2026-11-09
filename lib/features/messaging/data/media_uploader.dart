import 'dart:io';

import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/time/clock.dart';
import '../../../data_platform/db/app_database.dart';
import '../../../data_platform/db/synced_write.dart';
import '../../../data_platform/supabase/supabase_bootstrap.dart';
import '../../../features/health/data/health_incident_photo_storage.dart';
import '../domain/link_quality.dart';
import '../domain/media_policy.dart';
import 'case_message_synced_table.dart';
import 'case_photo_compressor.dart';

class MediaUploader {
  MediaUploader({
    required AppDatabase db,
    required SyncedWrite write,
    required Clock clock,
    SupabaseClient? client,
  })  : _db = db,
        _write = write,
        _clock = clock,
        _client = client ?? supabaseClient;

  static const maxConcurrentPoor = 1;
  static const cacheBudgetBytes = 50 * 1024 * 1024;

  final AppDatabase _db;
  final SyncedWrite _write;
  final Clock _clock;
  final SupabaseClient _client;
  final _compressor = const CasePhotoCompressor();
  final _policy = const MediaPolicy();
  var _inFlight = 0;

  Future<void> processDue({
    required LinkQualityLevel quality,
    required bool metered,
    required bool dataSaver,
  }) async {
    final now = _clock.now();
    final jobs = await (_db.select(_db.mediaUploadJobs)
          ..where(
            (t) =>
                t.state.equals('queued') |
                t.state.equals('failed'),
          ))
        .get();
    for (final job in jobs) {
      if (_inFlight >= maxConcurrentPoor &&
          (quality == LinkQualityLevel.poor ||
              quality == LinkQualityLevel.fair)) {
        break;
      }
      if (job.nextAttemptAt != null && job.nextAttemptAt!.isAfter(now)) {
        continue;
      }
      final decision = _policy.decide(
        quality: quality,
        metered: metered,
        dataSaver: dataSaver,
        sizeBytes: 0,
        userForced: job.userForced,
      );
      if (!decision.sendNow) continue;
      await _upload(job, decision);
    }
  }

  Future<void> sendNow(String jobId) async {
    final job = await (_db.select(_db.mediaUploadJobs)
          ..where((t) => t.id.equals(jobId)))
        .getSingleOrNull();
    if (job == null) return;
    await (_db.update(_db.mediaUploadJobs)..where((t) => t.id.equals(jobId)))
        .write(const MediaUploadJobsCompanion(userForced: Value(true)));
    await _upload(
      job.copyWith(userForced: true),
      const MediaPolicy().decide(
        quality: LinkQualityLevel.good,
        metered: false,
        dataSaver: false,
        sizeBytes: 0,
        userForced: true,
      ),
    );
  }

  Future<void> cancelAll() async {
    await _db.delete(_db.mediaUploadJobs).go();
    await _db.delete(_db.mediaCache).go();
  }

  Future<Uint8List?> loadCached(String objectKey) async {
    final row = await (_db.select(_db.mediaCache)
          ..where((t) => t.objectKey.equals(objectKey)))
        .getSingleOrNull();
    if (row == null) return null;
    final file = File(row.localPath);
    if (!await file.exists()) return null;
    await (_db.update(_db.mediaCache)
          ..where((t) => t.objectKey.equals(objectKey)))
        .write(MediaCacheCompanion(lastAccessAt: Value(_clock.now())));
    return file.readAsBytes();
  }

  Future<Uint8List?> downloadIfAllowed({
    required String objectKey,
    required LinkQualityLevel quality,
    required bool metered,
    required bool dataSaver,
    required bool userTapped,
  }) async {
    final cached = await loadCached(objectKey);
    if (cached != null) return cached;
    if (!userTapped &&
        (quality == LinkQualityLevel.poor || (metered && dataSaver))) {
      return null;
    }
    try {
      final bytes = await _client.storage
          .from(HealthIncidentPhotoStorage.bucketId)
          .download(objectKey);
      await _putCache(objectKey, bytes);
      return bytes;
    } catch (_) {
      return null;
    }
  }

  Future<void> _upload(MediaUploadJobRow job, MediaDecision decision) async {
    _inFlight++;
    await (_db.update(_db.mediaUploadJobs)..where((t) => t.id.equals(job.id)))
        .write(const MediaUploadJobsCompanion(state: Value('uploading')));
    try {
      final file = File(job.localPath);
      if (!await file.exists()) {
        throw const FileSystemException('missing');
      }
      final compressed = _compressor.compressFile(file, decision);
      final attachment = await (_db.select(_db.caseMessageAttachments)
            ..where((t) => t.id.equals(job.attachmentId)))
          .getSingle();
      await _client.storage.from(HealthIncidentPhotoStorage.bucketId).uploadBinary(
            attachment.objectKey,
            compressed.bytes,
            fileOptions: const FileOptions(
              upsert: true,
              contentType: 'image/jpeg',
            ),
          );
      final updated = CaseMessageAttachmentRow(
        id: attachment.id,
        farmId: attachment.farmId,
        requestId: attachment.requestId,
        messageId: attachment.messageId,
        createdAt: attachment.createdAt,
        updatedAt: _clock.now(),
        deletedAt: attachment.deletedAt,
        serverVersion: attachment.serverVersion,
        objectKey: attachment.objectKey,
        mime: attachment.mime,
        bytes: compressed.bytes.length,
        width: compressed.width,
        height: compressed.height,
        thumbB64: attachment.thumbB64,
        status: 'uploaded',
      );
      await _write.writeSynced(
        writeRow: () async {
          await (_db.update(_db.caseMessageAttachments)
                ..where((t) => t.id.equals(attachment.id)))
              .write(
            CaseMessageAttachmentsCompanion(
              status: const Value('uploaded'),
              bytes: Value(compressed.bytes.length),
              updatedAt: Value(_clock.now()),
            ),
          );
          await (_db.update(_db.mediaUploadJobs)
                ..where((t) => t.id.equals(job.id)))
              .write(const MediaUploadJobsCompanion(state: Value('uploaded')));
        },
        table: CaseMessageAttachmentSyncedTable().tableName,
        rowId: attachment.id,
        op: 'upsert',
        payload: CaseMessageAttachmentSyncedTable().toPayload(updated),
      );
    } catch (_) {
      final attempts = job.attempts + 1;
      final delay = Duration(seconds: (1 << attempts.clamp(0, 6)) + (attempts % 3));
      await (_db.update(_db.mediaUploadJobs)..where((t) => t.id.equals(job.id)))
          .write(
        MediaUploadJobsCompanion(
          state: const Value('failed'),
          attempts: Value(attempts),
          nextAttemptAt: Value(_clock.now().add(delay)),
        ),
      );
    } finally {
      _inFlight--;
    }
  }

  Future<void> _putCache(String objectKey, Uint8List bytes) async {
    final existing = await _db.select(_db.mediaCache).get();
    var used = existing.fold<int>(0, (sum, row) => sum + row.bytes);
    existing.sort((a, b) => a.lastAccessAt.compareTo(b.lastAccessAt));
    for (final row in existing) {
      if (used + bytes.length <= cacheBudgetBytes) break;
      await (_db.delete(_db.mediaCache)
            ..where((t) => t.objectKey.equals(row.objectKey)))
          .go();
      used -= row.bytes;
    }
    await _db.into(_db.mediaCache).insertOnConflictUpdate(
          MediaCacheRow(
            objectKey: objectKey,
            localPath: objectKey,
            bytes: bytes.length,
            lastAccessAt: _clock.now(),
          ),
        );
  }
}
