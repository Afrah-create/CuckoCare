import 'package:supabase_flutter/supabase_flutter.dart';

import 'secure_local_storage.dart';

/// Drift [AuthSnapshot] is the app login gate. Drop orphaned Supabase sessions
/// so GoTrue does not refresh tokens while the user is on the sign-in screen.
Future<void> reconcileSupabaseWithLocalSnapshot({
  required Future<bool> Function() hasLocalAuthSnapshot,
}) async {
  if (await hasLocalAuthSnapshot()) {
    return;
  }
  try {
    await Supabase.instance.client.auth.signOut(scope: SignOutScope.local);
  } catch (_) {
    // Best-effort; local sign-out should not require network.
  }
}

/// Restores persisted session and refreshes JWT before any Supabase RPC/sync.
///
/// Returns false when there is no usable session (caller should skip remote work).
Future<bool> ensureSupabaseSessionForNetwork() async {
  final GoTrueClient auth;
  try {
    auth = Supabase.instance.client.auth;
  } catch (_) {
    return false;
  }
  if (auth.currentSession == null) {
    final storage = SecureLocalStorage();
    if (await storage.hasAccessToken()) {
      final persisted = await storage.accessToken();
      if (persisted != null && persisted.isNotEmpty) {
        try {
          await auth.recoverSession(persisted);
        } catch (_) {
          // Expired or corrupt persisted session.
        }
      }
    }
  }
  if (auth.currentSession == null) {
    return false;
  }
  await refreshSupabaseSessionIfStale();
  return auth.currentSession != null;
}

/// Refresh JWT only when sync is about to run (connectivity already confirmed).
Future<void> refreshSupabaseSessionIfStale() async {
  final auth = Supabase.instance.client.auth;
  final session = auth.currentSession;
  if (session == null) {
    return;
  }

  final expiresAtSec = session.expiresAt;
  if (expiresAtSec == null) {
    return;
  }

  final expiresAt =
      DateTime.fromMillisecondsSinceEpoch(expiresAtSec * 1000, isUtc: true);
  final now = DateTime.now().toUtc();
  if (now.isBefore(expiresAt.subtract(const Duration(seconds: 60)))) {
    return;
  }

  try {
    await auth.refreshSession();
  } catch (_) {
    // Offline or server error; sync layer will surface auth/offline state.
  }
}
