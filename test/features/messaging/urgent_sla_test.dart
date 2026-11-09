import 'package:cucocare/features/messaging/domain/urgent_sla.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('explainer uses the reply SLA clock', () {
    const sla = UrgentSla(replyMinutes: 60);
    final text = sla.waitingExplainer(
      submittedAt: DateTime.utc(2026, 3, 1, 12),
    );
    expect(text, contains('urgent'));
    expect(text, contains('SMS'));
  });
}
