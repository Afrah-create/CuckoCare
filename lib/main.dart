import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/di/providers.dart';
import 'bootstrap.dart';
import 'core/config/env.dart';
import 'data_platform/db/app_database.dart';
import 'data_platform/notifications/local_reminder_scheduler.dart';

Future<void> main() async {
  final env = Env.fromEnvironment();
  final db = AppDatabase();
  final reminders = LocalReminderScheduler();
  final container = ProviderContainer(
    overrides: [
      envProvider.overrideWithValue(env),
      appDatabaseProvider.overrideWithValue(db),
    ],
  );

  await bootstrap(
    env: env,
    db: db,
    syncScheduler: container.read(syncSchedulerProvider),
    reminders: reminders,
  );

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const CucoCareApp(),
    ),
  );
}
