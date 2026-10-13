import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../app/di/providers.dart';
import '../../../app/layout/app_page.dart';
import '../../../app/layout/layout_scope.dart';
import '../../../app/layout/page_layout.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../../app/widgets/discard_changes_scope.dart';
import '../../../app/widgets/inline_banner.dart';
import '../../../app/widgets/states/app_dialog.dart';
import '../../../app/widgets/states/app_haptics.dart';
import '../../../app/widgets/states/async_state_view.dart';
import '../../../app/widgets/states/error_state.dart';
import '../../../app/widgets/states/not_found_state.dart';
import '../../../app/widgets/states/progress_button.dart';
import '../../../app/widgets/states/screen_skeletons.dart';
import '../../../app/widgets/sticky_action_bar.dart';
import '../../../core/error/failure_mapper.dart';
import '../../../core/error/result.dart';
import '../../../core/logging/app_logger.dart';
import '../data/batch_management.dart';
import '../domain/batch_rules.dart';
import '../domain/calendar_date.dart';
import 'batch_actions.dart';
import 'batch_display.dart';
import 'batch_labels.dart';
import 'batch_providers.dart';

/// Edits name, notes, source, initial count and arrival details.
class BatchEditScreen extends ConsumerStatefulWidget {
  const BatchEditScreen({required this.batchId, super.key});

  final String batchId;

  @override
  ConsumerState<BatchEditScreen> createState() => _BatchEditScreenState();
}

class _BatchEditScreenState extends ConsumerState<BatchEditScreen> {
  final _name = TextEditingController();
  final _source = TextEditingController();
  final _notes = TextEditingController();
  final _count = TextEditingController();
  final _age = TextEditingController();
  CalendarDate? _acquiredOn;
  Map<String, dynamic>? _draft;
  var _seeded = false;
  var _dirty = false;
  String? _error;

  String get _draftKey => 'batch:edit:${widget.batchId}';

  @override
  void initState() {
    super.initState();
    _loadDraft();
  }

  @override
  void dispose() {
    // Drafts only need to outlive process death; leaving the screen discards them.
    unawaited(_clearDraft());
    _name.dispose();
    _source.dispose();
    _notes.dispose();
    _count.dispose();
    _age.dispose();
    super.dispose();
  }

  Future<void> _loadDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_draftKey);
      if (raw == null || !mounted) {
        return;
      }
      _draft = jsonDecode(raw) as Map<String, dynamic>;
      if (_seeded) {
        setState(_applyDraft);
      }
    } catch (error) {
      appLogger.w('Ignoring unreadable batch edit draft', error: error);
    }
  }

  void _applyDraft() {
    final draft = _draft;
    if (draft == null) {
      return;
    }
    _name.text = draft['name'] as String? ?? _name.text;
    _source.text = draft['source'] as String? ?? _source.text;
    _notes.text = draft['notes'] as String? ?? _notes.text;
    _count.text = draft['count'] as String? ?? _count.text;
    _age.text = draft['age'] as String? ?? _age.text;
    final acquired = draft['acquiredOn'] as String?;
    if (acquired != null) {
      _acquiredOn = CalendarDate.parseIso(acquired);
    }
    _dirty = true;
    _draft = null;
  }

  Future<void> _saveDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _draftKey,
      jsonEncode({
        'name': _name.text,
        'source': _source.text,
        'notes': _notes.text,
        'count': _count.text,
        'age': _age.text,
        'acquiredOn': _acquiredOn?.toIso(),
      }),
    );
  }

  Future<void> _clearDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_draftKey);
  }

  void _changed() {
    setState(() {
      _dirty = true;
      _error = null;
    });
    unawaited(_saveDraft());
  }

  void _seed(BatchView view) {
    if (_seeded) {
      return;
    }
    _seeded = true;
    final batch = view.batch;
    _name.text = batch.name;
    _source.text = batch.source ?? '';
    _notes.text = batch.notes ?? '';
    _count.text = '${batch.initialCount}';
    _age.text = '${batch.ageAtAcquisitionDays}';
    _acquiredOn = view.facts.acquiredOn;
    _applyDraft();
  }

  BatchEdit _edit() {
    return BatchEdit(
      name: _name.text,
      notes: _notes.text,
      source: _source.text,
      initialCount: int.tryParse(_count.text.trim()) ?? 0,
      acquiredOn: _acquiredOn!,
      ageAtAcquisitionDays: int.tryParse(_age.text.trim()) ?? 0,
    );
  }

  Future<bool> _save() async {
    final management = ref.read(batchManagementProvider);
    final edit = _edit();
    final preview = await management.previewEdit(widget.batchId, edit);
    if (!mounted) {
      return false;
    }
    final BatchEditImpact impact;
    switch (preview) {
      case Success(:final value):
        impact = value;
      case Error(:final failure):
        setState(() => _error = failureText(failure));
        return false;
    }

    final effects = <String>[
      if (impact.changesLiveCount)
        'Live birds will change from ${formatCount(impact.liveBefore)} '
            'to ${formatCount(impact.liveAfter)}.',
      if (impact.movesTasks)
        '${impact.pendingTasksToMove == 1 ? '1 pending task' : '${impact.pendingTasksToMove} pending tasks'} '
            'will move ${impact.shiftDays.abs()} '
            '${impact.shiftDays.abs() == 1 ? 'day' : 'days'} '
            '${impact.shiftDays > 0 ? 'later' : 'earlier'}.',
    ];
    if (effects.isNotEmpty) {
      final confirmed = await showConfirmDialog(
        context: context,
        title: 'Save changes?',
        message: effects.join('\n'),
        confirmLabel: 'Save changes',
      );
      if (confirmed != true || !mounted) {
        return false;
      }
    }

    final afterWrite = afterBatchWrite(ref);
    final result = await management.updateBatchDetails(widget.batchId, edit);
    if (!mounted) {
      return false;
    }
    switch (result) {
      case Success():
        setState(() => _dirty = false);
        await _clearDraft();
        afterWrite();
        AppHaptics.success();
        return true;
      case Error(:final failure):
        setState(() => _error = failureText(failure));
        return false;
    }
  }

  Future<void> _pickArrival(CalendarDate today) async {
    final current = _acquiredOn ?? today;
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(current.year, current.month, current.day),
      firstDate: DateTime(today.year - 3),
      lastDate: DateTime(today.year, today.month, today.day),
    );
    if (picked != null) {
      _acquiredOn = CalendarDate.fromDateTime(picked);
      _changed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewAsync = ref.watch(batchViewProvider(widget.batchId));
    final today = ref.watch(todayDateProvider);
    final permissions = ref.watch(batchPermissionsProvider);
    final view = viewAsync.value;
    if (view != null) {
      _seed(view);
    }
    final blocked = view == null
        ? null
        : permissions.manageBlockedReason ??
              (view.isClosed ? BatchRules.closedReadOnly : null);

    return DiscardChangesScope(
      isDirty: _dirty,
      child: AppPage(
        title: 'Edit batch',
        preset: PageLayout.form,
        scroll: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Close',
          onPressed: () => context.pop(),
        ),
        bottom: view == null
            ? null
            : StickyActionBar(
                child: ProgressButton(
                  label: 'Save changes',
                  busyLabel: 'Saving…',
                  onPressed: blocked == null ? _save : null,
                  onSuccess: () => context.pop(true),
                ),
              ),
        body: AsyncStateView(
          value: viewAsync,
          expand: false,
          skeleton: const FormSkeleton(),
          onRetry: () => ref.invalidate(batchViewProvider(widget.batchId)),
          error: (error, _) => ErrorState(
            failure: FailureMapper.mapObject(error),
            onRetry: () => ref.invalidate(batchViewProvider(widget.batchId)),
          ),
          builder: (data) {
            if (data == null) {
              return NotFoundState(onBack: () => context.pop());
            }
            final enabled = blocked == null;
            final losses = data.metrics.totalLosses;
            final arrival = _ArrivalField(
              value: _acquiredOn ?? data.facts.acquiredOn,
              enabled: enabled,
              onTap: () => _pickArrival(today),
            );
            final age = TextField(
              controller: _age,
              enabled: enabled,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ],
              decoration: const InputDecoration(
                hintText: 'Days',
                suffixText: 'days',
              ),
              onChanged: (_) => _changed(),
            );
            return Padding(
              padding: const EdgeInsets.only(
                top: AppSpacing.md,
                bottom: AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (blocked != null) ...[
                    InlineBanner(
                      message: blocked,
                      icon: Icons.lock_outline,
                      tone: BannerTone.info,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                  if (_error != null) ...[
                    InlineBanner(message: _error!, icon: Icons.info_outline),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                  _Section(
                    title: 'Details',
                    children: [
                      _LabeledField(
                        label: 'Batch name',
                        child: TextField(
                          controller: _name,
                          enabled: enabled,
                          textCapitalization: TextCapitalization.words,
                          onChanged: (_) => _changed(),
                        ),
                      ),
                      _LabeledField(
                        label: 'Source',
                        optional: true,
                        child: TextField(
                          controller: _source,
                          enabled: enabled,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            hintText: 'Hatchery or supplier',
                          ),
                          onChanged: (_) => _changed(),
                        ),
                      ),
                      _LabeledField(
                        label: 'Notes',
                        optional: true,
                        child: TextField(
                          controller: _notes,
                          enabled: enabled,
                          minLines: 2,
                          maxLines: 4,
                          textCapitalization: TextCapitalization.sentences,
                          onChanged: (_) => _changed(),
                        ),
                      ),
                    ],
                  ),
                  _Section(
                    title: 'Birds',
                    children: [
                      _LabeledField(
                        label: 'Birds placed',
                        helper: losses == 0
                            ? 'Correct this if it was entered wrong.'
                            : 'Must be at least ${formatCount(losses)}, '
                                  'the birds already recorded as lost.',
                        child: TextField(
                          controller: _count,
                          enabled: enabled,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(6),
                          ],
                          decoration: const InputDecoration(
                            suffixText: 'birds',
                          ),
                          onChanged: (_) => _changed(),
                        ),
                      ),
                    ],
                  ),
                  _Section(
                    title: 'Arrival',
                    footnote:
                        'Changing these moves pending tasks by the same '
                        'number of days.',
                    children: [
                      if (context.layout.isLargeText) ...[
                        _LabeledField(label: 'Arrival date', child: arrival),
                        _LabeledField(label: 'Age at arrival', child: age),
                      ] else
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: _LabeledField(
                                label: 'Arrival date',
                                child: arrival,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              flex: 2,
                              child: _LabeledField(
                                label: 'Age at arrival',
                                child: age,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  _FixedDetails(birdType: birdTypeLabel(data.batch.birdType)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ArrivalField extends StatelessWidget {
  const _ArrivalField({
    required this.value,
    required this.enabled,
    required this.onTap,
  });

  final CalendarDate value;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Arrival date, ${formatDay(value)}',
      excludeSemantics: true,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: InputDecorator(
          decoration: InputDecoration(
            enabled: enabled,
            suffixIcon: const Icon(Icons.calendar_today_outlined),
          ),
          child: Text(
            formatDay(value),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}

/// A titled group of fields with even spacing.
class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children, this.footnote});

  final String title;
  final List<Widget> children;
  final String? footnote;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: context.text.titleSmall?.copyWith(
              color: context.scheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.md),
            children[i],
          ],
          if (footnote != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              footnote!,
              style: context.text.bodySmall?.copyWith(
                color: context.scheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Label above the field, so it never collides with the filled input.
class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.child,
    this.helper,
    this.optional = false,
  });

  final String label;
  final Widget child;
  final String? helper;
  final bool optional;

  @override
  Widget build(BuildContext context) {
    final muted = context.scheme.onSurfaceVariant;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text.rich(
          TextSpan(
            text: label,
            children: [
              if (optional)
                TextSpan(
                  text: '  Optional',
                  style: context.text.bodySmall?.copyWith(color: muted),
                ),
            ],
          ),
          style: context.text.labelLarge,
        ),
        const SizedBox(height: AppSpacing.xs),
        child,
        if (helper != null) ...[
          const SizedBox(height: AppSpacing.xxs),
          Text(helper!, style: context.text.bodySmall?.copyWith(color: muted)),
        ],
      ],
    );
  }
}

/// Details chosen at creation that drive the care schedule.
class _FixedDetails extends StatelessWidget {
  const _FixedDetails({required this.birdType});

  final String birdType;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final muted = context.text.bodySmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );
    return Card(
      margin: EdgeInsets.zero,
      color: scheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 18,
                  color: scheme.onSurfaceVariant,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    'Set when the batch was created',
                    style: context.text.titleSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            _FixedRow(label: 'Bird type', value: birdType),
            const SizedBox(height: AppSpacing.xs),
            const _FixedRow(
              label: 'Care schedule',
              value: 'Matched to bird type',
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              "These can't be changed. If one is wrong, delete this batch "
              'and add it again.',
              style: muted,
            ),
          ],
        ),
      ),
    );
  }
}

class _FixedRow extends StatelessWidget {
  const _FixedRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: context.text.bodyMedium?.copyWith(
              color: context.scheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: context.text.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
