import 'package:cucocare/data_platform/sync/sync_apply.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('shouldApplyRemoteVersion', () {
    final t0 = DateTime.utc(2026, 1, 1);
    final t1 = DateTime.utc(2026, 1, 2);

    test('unsynced local never accepts remote', () {
      expect(
        SyncApply.shouldApplyRemoteVersion(
          localServerVersion: null,
          localUpdatedAt: t1,
          incomingServerVersion: 99,
          incomingUpdatedAt: t0,
        ),
        isFalse,
      );
    });

    test('remote wins on higher server version', () {
      expect(
        SyncApply.shouldApplyRemoteVersion(
          localServerVersion: 1,
          localUpdatedAt: t1,
          incomingServerVersion: 2,
          incomingUpdatedAt: t0,
        ),
        isTrue,
      );
    });

    test('same version uses updated_at', () {
      expect(
        SyncApply.shouldApplyRemoteVersion(
          localServerVersion: 2,
          localUpdatedAt: t1,
          incomingServerVersion: 2,
          incomingUpdatedAt: t0,
        ),
        isFalse,
      );
      expect(
        SyncApply.shouldApplyRemoteVersion(
          localServerVersion: 2,
          localUpdatedAt: t0,
          incomingServerVersion: 2,
          incomingUpdatedAt: t1,
        ),
        isTrue,
      );
    });
  });
}
