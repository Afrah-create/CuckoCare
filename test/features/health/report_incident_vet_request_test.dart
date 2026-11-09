import 'package:cucocare/core/time/clock.dart';
import 'package:cucocare/data_platform/db/app_database.dart';
import 'package:cucocare/data_platform/db/synced_write.dart';
import 'package:cucocare/features/batches/data/batch_repository.dart';
import 'package:cucocare/features/health/data/health_incident_photo_storage.dart';
import 'package:cucocare/features/health/data/health_repository.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase/supabase.dart';

void main() {
  late AppDatabase db;
  late HealthRepository health;
  const farmId = 'farm-1';
  late String batchId;
  final now = DateTime.utc(2026, 3, 1, 12);

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    final write = SyncedWrite(db);
    health = HealthRepository(
      db,
      write,
      resolvePrimaryFarm: () async => null,
      clock: FixedClock(now),
      photoStorage: HealthIncidentPhotoStorage(
        client: SupabaseClient('https://example.supabase.co', 'test-anon-key'),
      ),
    );
    await db.into(db.farms).insert(
          FarmsCompanion.insert(
            id: farmId,
            farmId: farmId,
            name: 'Test farm',
            createdAt: now,
            updatedAt: now,
          ),
        );
    await BatchRepository(db, FixedClock(now)).createBatch(
      farmId: farmId,
      name: 'Batch A',
      birdType: 'broiler',
      initialCount: 100,
      acquiredOn: now,
      programmeId: 'prog',
      programmeVersion: 1,
    );
    batchId = (await db.select(db.batches).get()).single.id;
  });

  tearDown(() async {
    await db.close();
  });

  test('reportConcern always creates linked vet assistance row', () async {
    await health.reportConcern(
      ReportHealthConcernInput(
        batchId: batchId,
        farmId: farmId,
        summary: 'Coughing birds',
        requestVet: true,
      ),
    );

    final healthRows = await db.select(db.healthRecords).get();
    final vetRows = await db.select(db.vetAssistanceRequests).get();
    expect(healthRows, hasLength(1));
    expect(vetRows, hasLength(1));
    expect(vetRows.single.healthRecordId, healthRows.single.id);
    expect(vetRows.single.status, 'submitted');
    final outbox = await db.select(db.outbox).get();
    expect(
      outbox.where((o) => o.targetTable == 'batches').length,
      1,
    );
    expect(
      outbox.where((o) => o.targetTable == 'health_records').length,
      1,
    );
    expect(
      outbox.where((o) => o.targetTable == 'vet_assistance_requests').length,
      1,
    );
  });

  test('repairIncidentOutbox mints a new op for failed health rows', () async {
    await health.reportConcern(
      ReportHealthConcernInput(
        batchId: batchId,
        farmId: farmId,
        summary: 'Coughing birds',
        requestVet: true,
      ),
    );
    final first = (await db.select(db.outbox).get())
        .firstWhere((o) => o.targetTable == 'health_records');
    await (db.update(db.outbox)..where((o) => o.opId.equals(first.opId))).write(
      const OutboxCompanion(
        state: Value('failed'),
        retryable: Value(false),
        errorCode: Value('42501'),
      ),
    );
    await health.repairIncidentOutbox();
    final after = (await db.select(db.outbox).get())
        .where((o) => o.targetTable == 'health_records');
    expect(after, hasLength(1));
    expect(after.first.opId, isNot(first.opId));
    expect(after.first.state, 'pending');
  });

  test('repairIncidentOutbox requeues rows whose outbox was dropped', () async {
    await health.reportConcern(
      ReportHealthConcernInput(
        batchId: batchId,
        farmId: farmId,
        summary: 'Coughing birds',
        requestVet: true,
      ),
    );
    await db.outboxDao.deleteAllRows();
    await health.repairIncidentOutbox();
    final tables = (await db.select(db.outbox).get())
        .map((o) => o.targetTable)
        .toSet();
    expect(
      tables,
      containsAll(['batches', 'health_records', 'vet_assistance_requests']),
    );
  });

  test('requestVet off stores draft vet request', () async {
    await health.reportConcern(
      ReportHealthConcernInput(
        batchId: batchId,
        farmId: farmId,
        summary: 'Low appetite',
        requestVet: false,
      ),
    );

    final vetRows = await db.select(db.vetAssistanceRequests).get();
    expect(vetRows.single.status, 'draft');
  });

  test('publishDraftVetRequest upgrades status', () async {
    await health.reportConcern(
      ReportHealthConcernInput(
        batchId: batchId,
        farmId: farmId,
        summary: 'Draft case',
        requestVet: false,
      ),
    );
    final draftId = (await db.select(db.vetAssistanceRequests).get()).single.id;
    await health.publishDraftVetRequest(draftId);
    final updated =
        await (db.select(db.vetAssistanceRequests)..where((v) => v.id.equals(draftId)))
            .getSingle();
    expect(updated.status, 'submitted');
  });
}
