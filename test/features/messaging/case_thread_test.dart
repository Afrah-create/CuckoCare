import 'package:cucocare/features/messaging/domain/case_thread.dart';
import 'package:cucocare/features/messaging/domain/message_delivery_state.dart';
import 'package:flutter_test/flutter_test.dart';

CaseThreadMessage msg({
  required String id,
  required DateTime created,
  DateTime? written,
  int? version,
  String sender = 'u1',
  String role = 'farmer',
}) {
  return CaseThreadMessage(
    id: id,
    requestId: 'r1',
    senderUserId: sender,
    senderRole: role,
    kind: 'text',
    body: id,
    clientCreatedAt: written ?? created,
    createdAt: created,
    serverVersion: version,
    delivery: const MessageDeliveryState(MessageDeliveryKind.sent),
  );
}

void main() {
  final t0 = DateTime.utc(2026, 3, 1, 12);
  final t1 = t0.add(const Duration(minutes: 1));
  final t2 = t0.add(const Duration(hours: 4));

  test('pending messages sit at the bottom after server order', () {
    final ordered = CaseThread.order([
      msg(id: 'b', created: t1, version: 2),
      msg(id: 'pending', created: t0, version: null),
      msg(id: 'a', created: t0, version: 1),
    ]);
    expect(ordered.map((m) => m.id), ['a', 'b', 'pending']);
  });

  test('time label shows written and sent when they differ', () {
    final m = msg(id: 'x', created: t2, written: t0, version: 1);
    expect(CaseThread.timeLabel(m), contains('Written'));
    expect(CaseThread.timeLabel(m), contains('Sent'));
  });

  test('new messages divider is the first unread from the other party', () {
    final ordered = [
      msg(id: 'mine', created: t0, version: 1, sender: 'me'),
      msg(id: 'theirs', created: t1, version: 2, sender: 'vet', role: 'vet'),
    ];
    expect(
      CaseThread.newMessagesDividerIndex(
        ordered: ordered,
        lastReadAt: t0,
        myUserId: 'me',
      ),
      1,
    );
  });
}
