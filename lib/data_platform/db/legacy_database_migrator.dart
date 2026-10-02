import 'dart:io';

import 'package:drift_flutter/drift_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../features/auth/data/auth_snapshot_repository.dart';
import 'app_database.dart';
import 'local_database_identity.dart';

/// Moves the old shared `cucocare_v1` file to the active user's isolated DB once.
Future<void> migrateLegacySharedDatabaseIfNeeded({
  required String? activeUserId,
}) async {
  if (activeUserId == null || activeUserId.isEmpty) {
    return;
  }

  final dir = await getApplicationDocumentsDirectory();
  final legacyPath = p.join(dir.path, '$legacySharedDatabaseName.sqlite');
  final legacyFile = File(legacyPath);
  if (!legacyFile.existsSync()) {
    return;
  }

  final targetName = localDatabaseNameForAccount(activeUserId);
  final targetPath = p.join(dir.path, '$targetName.sqlite');
  if (File(targetPath).existsSync()) {
    return;
  }

  final legacyDb = AppDatabase.forAccount(
    null,
    driftDatabase(name: legacySharedDatabaseName),
  );
  try {
    final ownerId = await AuthSnapshotRepository(legacyDb).loadUserId();
    if (ownerId != activeUserId) {
      return;
    }
  } finally {
    await legacyDb.close();
  }

  await legacyFile.rename(targetPath);
  final wal = File('$legacyPath-wal');
  final shm = File('$legacyPath-shm');
  if (wal.existsSync()) {
    await wal.rename('$targetPath-wal');
  }
  if (shm.existsSync()) {
    await shm.rename('$targetPath-shm');
  }
}
