/// Decides whether the user may use the app without a live token refresh.
enum SessionAccess {
  unauthenticated,
  authenticatedOfflineCapable,
  requiresReSignIn,
}

class SessionGateInput {
  const SessionGateInput({
    required this.hasAuthSnapshot,
    required this.accessTokenExpired,
    required this.isOnline,
    required this.refreshExplicitlyRejected,
    required this.offlineGraceExpired,
  });

  final bool hasAuthSnapshot;
  final bool accessTokenExpired;
  final bool isOnline;
  final bool refreshExplicitlyRejected;
  final bool offlineGraceExpired;
}

class SessionGate {
  const SessionGate();

  SessionAccess evaluate(SessionGateInput input) {
    if (!input.hasAuthSnapshot) {
      return SessionAccess.unauthenticated;
    }

    if (input.refreshExplicitlyRejected && input.isOnline) {
      return SessionAccess.requiresReSignIn;
    }

    // Cached snapshot: full local access even when token expired offline.
    if (input.accessTokenExpired && !input.isOnline) {
      return SessionAccess.authenticatedOfflineCapable;
    }

    if (input.offlineGraceExpired) {
      // Grace expiry blocks sync/premium checks only; local records still allowed.
      return SessionAccess.authenticatedOfflineCapable;
    }

    return SessionAccess.authenticatedOfflineCapable;
  }

  bool blocksLocalRecords(SessionAccess access) =>
      access == SessionAccess.unauthenticated;

  bool blocksSync(SessionAccess access, SessionGateInput input) =>
      access == SessionAccess.requiresReSignIn || input.offlineGraceExpired;
}
