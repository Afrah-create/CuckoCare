# Local notifications (offline reminders)

## Flow

`ReminderPlanner` (pure Dart) → `ReminderReconciler` (diff against OS schedule) → `NotificationsGateway` / `FlutterLocalNotificationsGateway` (plugin only here).

## Preferences

Device-local `SharedPreferences`, loaded before `runApp`. Master switch off cancels all scheduled notifications immediately.

## Channels (do not rename)

- `schedule_due` — due / day-before
- `schedule_overdue` — overdue nudges

Scheduling uses `AndroidScheduleMode.inexactAllowWhileIdle` (no exact-alarm permissions).

## Settings

More → **Notifications** (`/more/settings/notifications`): master switch (confirm to turn off), due/overdue toggles, reminder time, next reminder preview.

## Manual QA (device)

See checklist in `docs/push.md` Part G — run on a real phone with airplane mode, recents swipe, and reboot.

## Limits

Force-stop clears alarms until the app opens again. OEM battery savers may delay delivery. Stale text possible if another device completed a task before sync.
