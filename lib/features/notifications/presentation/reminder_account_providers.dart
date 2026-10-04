import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/reminder_account_store.dart';

final reminderAccountStoreProvider = Provider<ReminderAccountStore>(
  (ref) => ReminderAccountStore(),
);

final initialReminderAccountUserIdProvider = Provider<String?>(
  (ref) => null,
);

final reminderAccountUserIdProvider =
    NotifierProvider<ReminderAccountUserIdNotifier, String?>(
  ReminderAccountUserIdNotifier.new,
);

class ReminderAccountUserIdNotifier extends Notifier<String?> {
  @override
  String? build() => ref.watch(initialReminderAccountUserIdProvider);

  void adopt(String userId) {
    state = userId;
  }
}

