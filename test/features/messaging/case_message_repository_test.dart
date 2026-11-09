import 'package:cucocare/core/time/clock.dart';
import 'package:cucocare/data_platform/db/app_database.dart';
import 'package:cucocare/data_platform/db/synced_write.dart';
import 'package:cucocare/features/messaging/data/case_message_repository.dart';
import 'package:cucocare/features/messaging/domain/message_delivery_state.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late CaseMessageRepository repo;
  final now = DateTime.utc(2026, 3, 1, 12);

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = CaseMessageRepository(
      db: db,
      write: SyncedWrite(db),
      clock: FixedClock(now),
      currentUserId: () => 'farmer-1',
      farmRole: () async => 'owner',
      isVet: () => false,
    );
  });

  tearDown(() async {
    await db.close();
  });

  test('sendText writes local row and outbox in one go', () async {
    await repo.sendText(
      requestId: 'req-1',
      farmId: 'farm-1',
      requestStatus: 'accepted',
      body: 'Birds are getting worse',
    );
    final messages = await db.select(db.caseMessages).get();
    final outbox = await db.select(db.outbox).get();
    expect(messages, hasLength(1));
    expect(messages.single.body, 'Birds are getting worse');
    expect(messages.single.senderRole, 'farmer');
    expect(
      outbox.where((o) => o.targetTable == 'case_messages'),
      hasLength(1),
    );
  });

  test('thread marks queued until acknowledged', () async {
    await repo.sendText(
      requestId: 'req-1',
      farmId: 'farm-1',
      requestStatus: 'accepted',
      body: 'Hello',
    );
    final thread = await repo.loadThread('req-1');
    expect(thread.single.delivery.kind, MessageDeliveryKind.queued);
  });

  test('retryFailed mints a new outbox op_id', () async {
    await repo.sendText(
      requestId: 'req-1',
      farmId: 'farm-1',
      requestStatus: 'accepted',
      body: 'Hello',
    );
    final first = (await db.select(db.outbox).get()).single;
    await (db.update(db.outbox)..where((o) => o.opId.equals(first.opId)))
        .write(
      const OutboxCompanion(
        state: Value('failed'),
        retryable: Value(false),
        errorCode: Value('42501'),
      ),
    );
    await repo.retryFailed(first.rowId);
    final after = await db.select(db.outbox).get();
    expect(after, hasLength(1));
    expect(after.single.opId, isNot(first.opId));
    expect(after.single.state, 'pending');
    expect(after.single.payload.contains('farm_id'), isTrue);
  });

  test('composer rejects closed cases locally', () async {
    expect(
      () => repo.sendText(
        requestId: 'req-1',
        farmId: 'farm-1',
        requestStatus: 'completed',
        body: 'Hello',
      ),
      throwsA(isA<StateError>()),
    );
  });
}
