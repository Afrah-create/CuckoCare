import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/lifecycle/app_lifecycle_service.dart';
import '../../core/time/kampala_today.dart';
import '../../features/notifications/presentation/notification_prefs_provider.dart';
import '../router/app_router.dart';
import '../router/deep_link_handler.dart';

/// Ensures [appLifecycleServiceProvider] is created for the process lifetime.
class LifecycleHost extends ConsumerWidget {
  const LifecycleHost({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(appLifecycleServiceProvider);
    ref.listen<int>(lifecycleResumeCountProvider, (previous, next) {
      if (previous == null) {
        return;
      }
      ref.read(reminderReconcilerProvider).scheduleReconcile();
      ref.invalidate(notificationsAvailabilityProvider);
      ref.read(deepLinkHandlerProvider).flush(ref.read(appRouterProvider));
    });
    return child;
  }
}
