import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/lifecycle/app_lifecycle_service.dart';

/// Ensures [appLifecycleServiceProvider] is created for the process lifetime.
class LifecycleHost extends ConsumerWidget {
  const LifecycleHost({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(appLifecycleServiceProvider);
    return child;
  }
}
