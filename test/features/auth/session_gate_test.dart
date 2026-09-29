import 'package:cucocare/features/auth/domain/session_gate.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const gate = SessionGate();

  test('expired token while offline still opens app', () {
    final access = gate.evaluate(
      const SessionGateInput(
        hasAuthSnapshot: true,
        accessTokenExpired: true,
        isOnline: false,
        refreshExplicitlyRejected: false,
        offlineGraceExpired: false,
      ),
    );
    expect(access, SessionAccess.authenticatedOfflineCapable);
    expect(gate.blocksLocalRecords(access), isFalse);
  });

  test('refresh rejected while online requires re-sign-in', () {
    final access = gate.evaluate(
      const SessionGateInput(
        hasAuthSnapshot: true,
        accessTokenExpired: true,
        isOnline: true,
        refreshExplicitlyRejected: true,
        offlineGraceExpired: false,
      ),
    );
    expect(access, SessionAccess.requiresReSignIn);
    expect(gate.blocksSync(access, const SessionGateInput(
      hasAuthSnapshot: true,
      accessTokenExpired: true,
      isOnline: true,
      refreshExplicitlyRejected: true,
      offlineGraceExpired: false,
    )), isTrue);
  });
}
