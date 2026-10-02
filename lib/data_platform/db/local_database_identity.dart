/// Stable Drift database file names per signed-in account (multi-user on one device).
String localDatabaseNameForAccount(String? userId) {
  if (userId == null || userId.trim().isEmpty) {
    return 'cucocare_guest';
  }
  final normalized = userId.trim().replaceAll('-', '').toLowerCase();
  return 'cucocare_u_$normalized';
}

/// Pre–per-account migration single-file name.
const legacySharedDatabaseName = 'cucocare_v1';
