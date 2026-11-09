import 'package:cucocare/features/messaging/domain/case_thread.dart';
import 'package:cucocare/features/messaging/domain/message_delivery_state.dart';
import 'package:cucocare/features/messaging/domain/message_metrics.dart';
import 'package:flutter_test/flutter_test.dart';

CaseThreadMessage m({
  required String id,
  required String requestId,
  required String sender,
  required String role,
  required DateTime at,
  int? version = 1,
}) {
  return CaseThreadMessage(
    id: id,
    requestId: requestId,
    senderUserId: sender,
    senderRole: role,
    kind: 'text',
    body: id,
    clientCreatedAt: at,
    createdAt: at,
    serverVersion: version,
    delivery: const MessageDeliveryState(MessageDeliveryKind.sent),
  );
}

void main() {
  const metrics = MessageMetrics();
  final t0 = DateTime.utc(2026, 3, 1, 10);
  final t1 = DateTime.utc(2026, 3, 1, 11);

  test('ignores own, system, and pending messages', () {
    final unread = metrics.unreadForCase(
      messages: [
        m(id: '1', requestId: 'a', sender: 'me', role: 'farmer', at: t1),
        m(id: '2', requestId: 'a', sender: 'sys', role: 'system', at: t1),
        m(
          id: '3',
          requestId: 'a',
          sender: 'vet',
          role: 'vet',
          at: t1,
          version: null,
        ),
        m(id: '4', requestId: 'a', sender: 'vet', role: 'vet', at: t1),
      ],
      myUserId: 'me',
      lastReadAt: t0,
    );
    expect(unread, 1);
  });

  test('grouped totals and badge cap', () {
    final grouped = metrics.grouped(
      messages: [
        m(id: '1', requestId: 'a', sender: 'vet', role: 'vet', at: t1),
        m(id: '2', requestId: 'b', sender: 'vet', role: 'vet', at: t1),
        m(id: '3', requestId: 'b', sender: 'vet', role: 'vet', at: t1),
      ],
      myUserId: 'me',
      lastReadByRequest: {'a': t0, 'b': t0},
    );
    expect(metrics.totalUnread(grouped), 3);
    expect(metrics.casesWithUnread(grouped), 2);
    expect(MessageMetrics.badgeLabel(0), '');
    expect(MessageMetrics.badgeLabel(12), '12');
    expect(MessageMetrics.badgeLabel(100), '99+');
  });
}
