import 'package:supabase_flutter/supabase_flutter.dart';

import '../supabase/offline_first_auth.dart';
import 'local_account_registry.dart';

/// Chooses the local DB owner on cold start (session wins, else last active account).
Future<String?> resolveLaunchAccountUserId(LocalAccountRegistry registry) async {
  await ensureSupabaseSessionForNetwork();
  final sessionUserId = Supabase.instance.client.auth.currentUser?.id;
  if (sessionUserId != null) {
    await registry.setActiveAccountId(sessionUserId);
    return sessionUserId;
  }
  return registry.readActiveAccountId();
}
