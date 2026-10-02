import 'package:flutter_riverpod/flutter_riverpod.dart';

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
