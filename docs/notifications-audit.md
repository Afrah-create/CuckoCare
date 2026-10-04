# Notifications audit (2026-10-04)

## Existing before this work

- `LocalReminderScheduler` scaffold with single `vaccination_reminders` channel and inexact `zonedSchedule`.
- Manifest: `POST_NOTIFICATIONS`, `RECEIVE_BOOT_COMPLETED`, boot/package-replaced receiver.
- No exact-alarm permissions.
- `DeepLinkHandler` for post-auth routing.
- Theme prefs pattern via `SharedPreferences` loaded before `runApp`.

## Gaps closed in this pass

- Device `NotificationPrefs` + repository, loaded before `runApp`.
- Pure `ReminderPlanner` for due/overdue grouping, horizon, and content hashes.
- `NotificationsGateway` + `FlutterLocalNotificationsGateway` (plugin isolated).
- Diff-based `ReminderReconciler` with debounce; cancel-all on sign-out.
- Channels `schedule_due` / `schedule_overdue`.
- Kotlin `ug.cucocare/system_settings` for notification and battery settings.
- `/more/settings/notifications` screen with master switch confirm, test notification, battery tips.
- Sign-out confirmation dialog app-wide.

## Still to deepen (follow-up)

- Reconcile hooks on every task/batch mutation and sync pull.
- Localised notification copy via `lookupAppLocalizations`.
- Today permission rationale banner (twice max).
- Snooze action + `reminder_snoozes` table.
- Full Part G widget/golden suite and ADRs.
