import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../../core/time/clock.dart';
import '../../core/time/kampala_time.dart';
import '../../features/batches/domain/calendar_date.dart';
import '../../features/notifications/domain/notification_prefs.dart';
import '../../features/notifications/domain/notification_prefs_repository.dart';
import '../../features/notifications/domain/planned_reminder.dart';
import '../../features/notifications/domain/reminder_planner.dart';
import '../db/app_database.dart';
import 'notifications_gateway.dart';
import 'reminder_plan_loader.dart';

class ReminderReconciler {
  ReminderReconciler({
    required NotificationsGateway gateway,
    required NotificationPrefsRepository prefsRepository,
    required AppDatabase Function() db,
    required Clock clock,
    required Future<String?> Function() reminderAccountId,
    ReminderPlanner? planner,
    ReminderPlanLoader? loader,
    Duration debounce = const Duration(milliseconds: 500),
  })  : _gateway = gateway,
        _prefsRepository = prefsRepository,
        _db = db,
        _clock = clock,
        _reminderAccountId = reminderAccountId,
        _planner = planner ?? ReminderPlanner(),
        _loader = loader ?? const ReminderPlanLoader(),
        _debounce = debounce;

  final NotificationsGateway _gateway;
  final NotificationPrefsRepository _prefsRepository;
  final AppDatabase Function() _db;
  final Clock _clock;
  final Future<String?> Function() _reminderAccountId;
  final ReminderPlanner _planner;
  final ReminderPlanLoader _loader;
  final Duration _debounce;

  Timer? _debounceTimer;
  Future<void>? _inFlight;

  DateTime? lastReconcileAt;
  String? lastPlanHash;

  void scheduleReconcile() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounce, () {
      unawaited(reconcile());
    });
  }

  Future<void> reconcile() async {
    if (_inFlight != null) {
      await _inFlight;
      return;
    }
    _inFlight = _reconcileInner();
    try {
      await _inFlight;
    } finally {
      _inFlight = null;
    }
  }

  Future<void> _reconcileInner() async {
    final prefs = await _prefsRepository.load();
    if (!prefs.remindersEnabled) {
      await _gateway.cancelAll();
      lastPlanHash = 'off';
      lastReconcileAt = _clock.now();
      return;
    }

    final osAllows = await _gateway.areNotificationsEnabled();
    if (!osAllows) {
      await _gateway.cancelAll();
      lastPlanHash = 'blocked';
      lastReconcileAt = _clock.now();
      return;
    }

    final accountId = await _reminderAccountId();
    if (accountId == null) {
      lastReconcileAt = _clock.now();
      return;
    }

    final loadResult = await _loader.load(_db());
    final today = CalendarDate.fromDateTime(
      KampalaTime.startOfDay(_clock.now()),
    );
    final plan = _planner.plan(
      prefs: prefs,
      tasks: loadResult.tasks,
      today: today,
      nowLocal: _clock.now(),
      farmCount: loadResult.farmCount,
    );

    final planHash = sha256.convert(utf8.encode(jsonEncode({
      'n': plan.length,
      'ids': plan.map((p) => '${p.notificationId}:${p.contentHash}').toList(),
    }))).toString();

    if (planHash == lastPlanHash) {
      lastReconcileAt = _clock.now();
      return;
    }

    final scheduled = await _gateway.scheduled();
    final scheduledById = {for (final s in scheduled) s.id: s.contentHash};

    final desiredIds = plan.map((p) => p.notificationId).toSet();

    for (final existing in scheduled) {
      if (!desiredIds.contains(existing.id)) {
        await _gateway.cancel(existing.id);
      }
    }

    for (final reminder in plan) {
      final existingHash = scheduledById[reminder.notificationId];
      if (existingHash == reminder.contentHash) {
        continue;
      }
      if (existingHash != null) {
        await _gateway.cancel(reminder.notificationId);
      }
      await _gateway.schedule(reminder);
    }

    lastPlanHash = planHash;
    lastReconcileAt = _clock.now();
  }

  Future<List<PlannedReminder>> previewPlan(NotificationPrefs prefs) async {
    if (await _reminderAccountId() == null) {
      return const [];
    }
    final loadResult = await _loader.load(_db());
    final today = CalendarDate.fromDateTime(
      KampalaTime.startOfDay(_clock.now()),
    );
    return _planner.plan(
      prefs: prefs,
      tasks: loadResult.tasks,
      today: today,
      nowLocal: _clock.now(),
      farmCount: loadResult.farmCount,
    );
  }
}
