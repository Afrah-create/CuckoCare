import 'package:cucocare/core/error/failure.dart';
import 'package:cucocare/core/error/failure_mapper.dart';
import 'package:cucocare/core/error/ui_failure.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every failure maps to a kind, a next step, and no raw exception', () {
    const failures = <Failure>[
      NetworkFailure(),
      AuthFailure('session'),
      StorageFailure('disk'),
      UnexpectedFailure('Exception: boom'),
      SyncOffline(),
      SyncTimeout(),
      SyncServerFailure('500', retryable: true),
      SyncAuthRequired(),
      SyncRejected('row changed'),
      SyncSchemaMismatch('v2'),
      SyncSignedOutDemo(),
      LocationPermissionDenied(),
      LocationPermissionPermanentlyDenied(),
      LocationServiceDisabled(),
      LocationCaptureTimeout(),
    ];

    for (final failure in failures) {
      final ui = FailureMapper.map(failure);
      expect(ui.title, isNotEmpty);
      expect(ui.message, isNotEmpty);
      expect(ui.code, isNotEmpty);
      expect(ui.message.toLowerCase(), isNot(contains('exception')));
      expect(ui.title.toLowerCase(), isNot(contains('exception')));
      expect(ui.message, isNot(contains('boom')));
    }
  });

  test('kinds choose a presentation and an action', () {
    expect(FailureMapper.map(const SyncOffline()).kind, UiFailureKind.offline);
    expect(
      FailureMapper.map(const SyncOffline()).action,
      UiAction.retry,
    );
    expect(
      FailureMapper.map(const SyncAuthRequired()).kind,
      UiFailureKind.authRequired,
    );
    expect(
      FailureMapper.map(const SyncAuthRequired()).action,
      UiAction.signIn,
    );
    expect(
      FailureMapper.map(const LocationPermissionPermanentlyDenied()).kind,
      UiFailureKind.permissionBlocked,
    );
    expect(
      FailureMapper.map(const LocationPermissionPermanentlyDenied()).action,
      UiAction.openSettings,
    );
    expect(
      FailureMapper.map(const StorageFailure('full')).kind,
      UiFailureKind.storageFull,
    );
    expect(
      FailureMapper.mapObject(LoadTimedOutShim()),
      isA<UiFailure>().having((f) => f.kind, 'kind', UiFailureKind.timeout),
    );
    expect(
      FailureMapper.mapObject(FakePostgrest('PGRST202', 'schema cache')).code,
      'PGRST202',
    );
    expect(
      FailureMapper.mapObject(FakePostgrest('42501', 'forbidden')).kind,
      UiFailureKind.permissionDenied,
    );
    expect(
      FailureMapper.mapObject(FakePostgrest('28000', 'not authenticated')).kind,
      UiFailureKind.authRequired,
    );
  });
}

class LoadTimedOutShim implements Exception {
  @override
  String toString() => 'LoadTimedOut';
}

class FakePostgrest {
  FakePostgrest(this.code, this.message);
  final String code;
  final String message;
}
