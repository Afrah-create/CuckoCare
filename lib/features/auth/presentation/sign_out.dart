import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';
import '../../notifications/presentation/notification_prefs_provider.dart';
import 'auth_form_state.dart';
import 'login_controller.dart';

Future<void> signOutFromApp(WidgetRef ref) async {
  try {
    await ref.read(authRepositoryProvider).signOut();
  } finally {
    ref.read(hasAuthSnapshotProvider.notifier).adoptSignedOut();
    ref.read(loginControllerProvider.notifier).resetForSignOut();
    bumpAuthFormGeneration(ref);
    ref.invalidate(userProfileProvider);
    ref.invalidate(appRoleProvider);
    ref.invalidate(farmProfileIncompleteProvider);
    ref.invalidate(primaryFarmProvider);
    ref.invalidate(syncStatusProvider);
    TextInput.finishAutofillContext(shouldSave: false);
    ref.read(reminderReconcilerProvider).scheduleReconcile();
  }
}
