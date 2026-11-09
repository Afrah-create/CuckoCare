import 'package:cucocare/features/messaging/domain/message_delivery_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('derives every delivery kind', () {
    expect(
      MessageDeliveryState.derive(
        inOutbox: true,
        inFlight: false,
        failed: false,
        failReason: null,
        hasServerVersion: false,
        seenByOther: false,
      ).kind,
      MessageDeliveryKind.queued,
    );
    expect(
      MessageDeliveryState.derive(
        inOutbox: true,
        inFlight: true,
        failed: false,
        failReason: null,
        hasServerVersion: false,
        seenByOther: false,
      ).kind,
      MessageDeliveryKind.sending,
    );
    expect(
      MessageDeliveryState.derive(
        inOutbox: false,
        inFlight: false,
        failed: false,
        failReason: null,
        hasServerVersion: true,
        seenByOther: false,
      ).kind,
      MessageDeliveryKind.sent,
    );
    expect(
      MessageDeliveryState.derive(
        inOutbox: false,
        inFlight: false,
        failed: false,
        failReason: null,
        hasServerVersion: true,
        seenByOther: true,
      ).kind,
      MessageDeliveryKind.seen,
    );
    expect(
      MessageDeliveryState.derive(
        inOutbox: false,
        inFlight: false,
        failed: true,
        failReason: 'Failed: this case is closed',
        hasServerVersion: false,
        seenByOther: false,
      ).reason,
      'Failed: this case is closed',
    );
  });
}
