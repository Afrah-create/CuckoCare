import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/notifications/presentation/notification_prefs_provider.dart';
import '../../features/notifications/presentation/reminder_account_providers.dart';
import 'local_account_registry.dart';

/// Which account's Drift database [appDatabaseProvider] should open.
class AccountSessionNotifier extends Notifier<String?> {
  @override
  String? build() => ref.watch(initialAccountUserIdProvider);

  Future<void> activate(String? userId) async {
    if (state == userId) {
      return;
    }
    await ref.read(localAccountRegistryProvider).setActiveAccountId(userId);
    state = userId;
    if (userId != null) {
      await ref.read(reminderAccountStoreProvider).set(userId);
      ref.read(reminderAccountUserIdProvider.notifier).adopt(userId);
      ref.read(reminderReconcilerProvider).scheduleReconcile();
    }
  }
}

final initialAccountUserIdProvider = Provider<String?>(
  (ref) => throw UnimplementedError('Override in main()'),
);

final localAccountRegistryProvider = Provider<LocalAccountRegistry>(
  (ref) => LocalAccountRegistry(),
);

final accountSessionProvider =
    NotifierProvider<AccountSessionNotifier, String?>(
  AccountSessionNotifier.new,
);
