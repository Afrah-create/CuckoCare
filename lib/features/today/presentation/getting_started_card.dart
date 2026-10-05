import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../app/di/providers.dart';
import '../../../app/router/routes/typed_routes.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../notifications/presentation/notification_prefs_provider.dart';

const _dismissedKey = 'getting_started_dismissed';

final gettingStartedDismissedProvider =
    NotifierProvider<GettingStartedDismissed, bool>(GettingStartedDismissed.new);

class GettingStartedDismissed extends Notifier<bool> {
  @override
  bool build() {
    _load();
    return false;
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getBool(_dismissedKey);
      if (stored == true) {
        state = true;
      }
    } catch (_) {}
  }

  Future<void> dismiss() async {
    state = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_dismissedKey, true);
    } catch (_) {}
  }
}

class GettingStartedCard extends ConsumerWidget {
  const GettingStartedCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(gettingStartedDismissedProvider)) {
      return const SizedBox.shrink();
    }
    final farm = ref.watch(primaryFarmProvider).value;
    final batches = ref.watch(activeBatchCountProvider).value ?? 0;
    final reminders = ref.watch(notificationPrefsProvider).remindersEnabled;
    final hasLocation = farm?.latitude != null && farm?.longitude != null;
    if (hasLocation && batches > 0 && reminders) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Getting started',
                    style: context.text.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Dismiss',
                  onPressed: () =>
                      ref.read(gettingStartedDismissedProvider.notifier).dismiss(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            Text(
              'Three short steps. You can do them offline.',
              style: context.text.bodySmall?.copyWith(
                color: context.scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _Step(
              done: hasLocation,
              label: 'Add farm location',
              onTap: () => const MoreFarmRoute().push(context),
            ),
            _Step(
              done: batches > 0,
              label: 'Add your first batch',
              onTap: () => const BatchNewRoute().push(context),
            ),
            _Step(
              done: reminders,
              label: 'Turn on reminders',
              onTap: () => const NotificationsSettingsRoute().push(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    required this.done,
    required this.label,
    required this.onTap,
  });

  final bool done;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        done ? Icons.check_circle : Icons.circle_outlined,
        color: done ? context.colors.success : context.scheme.onSurfaceVariant,
      ),
      title: Text(label),
      trailing: done ? null : const Icon(Icons.chevron_right),
      onTap: done ? null : onTap,
    );
  }
}
