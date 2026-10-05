import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/layout/content_frame.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../../app/widgets/cuco_confirm_dialog.dart';
import '../../../app/widgets/inline_banner.dart';
import '../../../app/widgets/states/async_state_view.dart';
import '../../../app/widgets/states/app_snack.dart';
import '../domain/notification_channels.dart';
import '../domain/notification_prefs.dart';
import '../domain/notifications_availability.dart';
import 'notification_prefs_provider.dart';

class NotificationsSettingsScreen extends ConsumerWidget {
  const NotificationsSettingsScreen({super.key});

  Future<void> _onMasterChanged(
    BuildContext context,
    WidgetRef ref,
    bool value,
  ) async {
    final prefs = ref.read(notificationPrefsProvider);
    if (!value) {
      final ok = await showCucoConfirmDialog(
        context: context,
        title: 'Turn off reminders?',
        message:
            'Scheduled alerts will be cleared. You can still see overdue tasks on Today.',
        confirmLabel: 'Turn off',
        cancelLabel: 'Keep on',
        destructive: true,
      );
      if (ok != true || !context.mounted) {
        return;
      }
      await ref.read(notificationPrefsProvider.notifier).update(
            prefs.copyWith(remindersEnabled: false),
          );
      await ref.read(notificationsGatewayProvider).cancelAll();
      return;
    }

    final gateway = ref.read(notificationsGatewayProvider);
    final granted = await gateway.requestPermission();
    if (!granted) {
      final nextDenials = prefs.permissionDenialCount + 1;
      await ref.read(notificationPrefsProvider.notifier).update(
            prefs.copyWith(permissionDenialCount: nextDenials),
          );
      if (context.mounted) {
        AppSnack.show(
          context,
          message:
              'Permission was not granted. You can enable alerts in system settings.',
        );
      }
      return;
    }
    await ref.read(notificationPrefsProvider.notifier).update(
          prefs.copyWith(remindersEnabled: true),
        );
  }

  Future<void> _pickTime(BuildContext context, WidgetRef ref) async {
    final prefs = ref.read(notificationPrefsProvider);
    final initial = TimeOfDay(
      hour: prefs.reminderTimeMinutes ~/ 60,
      minute: prefs.reminderTimeMinutes % 60,
    );
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      helpText: 'Remind me at',
    );
    if (picked == null || !context.mounted) {
      return;
    }
    final minutes = picked.hour * 60 + picked.minute;
    await ref.read(notificationPrefsProvider.notifier).update(
          prefs.copyWith(reminderTimeMinutes: minutes),
        );
  }

  void _close(BuildContext context) {
    final router = GoRouter.of(context);
    if (router.canPop()) {
      router.pop();
    } else {
      router.go('/more');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(notificationPrefsProvider);
    final availabilityAsync = ref.watch(notificationsAvailabilityProvider);
    final nextLine = ref.watch(nextPlannedReminderProvider);
    final scheme = context.scheme;
    final masterEnabled = prefs.remindersEnabled;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _close(context),
        ),
      ),
      body: ContentFrame(
        child: ListView(
          padding: EdgeInsets.only(
            bottom: ContentFrame.scrollBottomInset(context),
          ),
          children: [
            AsyncStateView(
              expand: false,
              value: availabilityAsync,
              skeleton: const SizedBox(height: 8),
              error: (_, _) => const SizedBox.shrink(),
              builder: (availability) =>
                  _BlockedBanner(availability: availability),
            ),
            const SizedBox(height: AppSpacing.sm),
            Card(
              child: SwitchListTile(
                title: const Text('Reminders'),
                subtitle: Text(
                  availabilityAsync.maybeWhen(
                    data: availabilitySubtitle,
                    orElse: () => masterEnabled ? 'On' : 'Off',
                  ),
                ),
                value: masterEnabled,
                onChanged: (v) => _onMasterChanged(context, ref, v),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'What to remind me about',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: scheme.primary,
                  ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Due reminders'),
                    subtitle: const Text('Day before and on the due date'),
                    value: prefs.dueRemindersEnabled,
                    onChanged: masterEnabled
                        ? (v) => ref
                            .read(notificationPrefsProvider.notifier)
                            .update(prefs.copyWith(dueRemindersEnabled: v))
                        : null,
                  ),
                  const Divider(height: 1, indent: 16),
                  SwitchListTile(
                    title: const Text('Overdue reminders'),
                    subtitle: const Text('After a task passes its due date'),
                    value: prefs.overdueRemindersEnabled,
                    onChanged: masterEnabled
                        ? (v) => ref
                            .read(notificationPrefsProvider.notifier)
                            .update(prefs.copyWith(overdueRemindersEnabled: v))
                        : null,
                  ),
                  if (prefs.overdueRemindersEnabled && masterEnabled) ...[
                    const Divider(height: 1, indent: 16),
                    RadioListTile<OverdueReminderMode>(
                      title: const Text('Day 1 and day 3'),
                      subtitle: const Text('Standard nudges after it is due'),
                      value: OverdueReminderMode.standard,
                      groupValue: prefs.overdueMode,
                      onChanged: (mode) {
                        if (mode == null) {
                          return;
                        }
                        ref
                            .read(notificationPrefsProvider.notifier)
                            .update(prefs.copyWith(overdueMode: mode));
                      },
                    ),
                    RadioListTile<OverdueReminderMode>(
                      title: const Text('Every day for a week'),
                      subtitle: const Text('Up to 7 days after the due date'),
                      value: OverdueReminderMode.daily,
                      groupValue: prefs.overdueMode,
                      onChanged: (mode) {
                        if (mode == null) {
                          return;
                        }
                        ref
                            .read(notificationPrefsProvider.notifier)
                            .update(prefs.copyWith(overdueMode: mode));
                      },
                    ),
                  ],
                ],
              ),
            ),
            if (!masterEnabled)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Text(
                  'Turn reminders on to change due and overdue options.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
              ),
            const SizedBox(height: AppSpacing.md),
            Card(
              child: ListTile(
                title: const Text('Remind me at'),
                subtitle: Text(_formatMinutes(prefs.reminderTimeMinutes)),
                trailing: const Icon(Icons.schedule_outlined),
                enabled: masterEnabled,
                onTap: masterEnabled ? () => _pickTime(context, ref) : null,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            AsyncStateView(
              expand: false,
              value: nextLine,
              skeleton: const SizedBox(height: 8),
              error: (_, _) => const SizedBox.shrink(),
              builder: (line) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  line,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatMinutes(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    final period = h >= 12 ? 'PM' : 'AM';
    final hour12 = h % 12 == 0 ? 12 : h % 12;
    if (m == 0) {
      return '$hour12:00 $period';
    }
    return '$hour12:${m.toString().padLeft(2, '0')} $period';
  }
}

class _BlockedBanner extends ConsumerWidget {
  const _BlockedBanner({required this.availability});

  final NotificationsAvailability availability;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final message = switch (availability) {
      NotificationsBlockedBySystem() =>
        'Notifications are blocked in Android settings. Open settings to allow them.',
      NotificationsChannelBlocked(:final kind) =>
        kind == NotificationBlockKind.due
            ? 'Due reminders are turned off for this app in system settings.'
            : 'Overdue reminders are turned off for this app in system settings.',
      _ => null,
    };
    if (message == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InlineBanner(
            message: message,
            icon: Icons.notifications_off_outlined,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () async {
                final gateway = ref.read(notificationsGatewayProvider);
                switch (availability) {
                  case NotificationsChannelBlocked(:final kind):
                    final channelId = kind == NotificationBlockKind.due
                        ? NotificationChannels.scheduleDue
                        : NotificationChannels.scheduleOverdue;
                    await gateway.openChannelSettings(channelId);
                  default:
                    await gateway.openAppNotificationSettings();
                }
              },
              child: const Text('Open settings'),
            ),
          ),
        ],
      ),
    );
  }
}
