import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../app/di/providers.dart';
import '../../../app/layout/adaptive.dart';
import '../../../app/layout/app_page.dart';
import '../../../app/layout/page_layout.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../../app/widgets/discard_changes_scope.dart';
import '../../../app/widgets/inline_banner.dart';
import '../../../app/widgets/sticky_action_bar.dart';
import '../../../app/widgets/states/app_haptics.dart';
import '../../../app/widgets/states/app_snack.dart';
import '../../../app/widgets/states/async_state_view.dart';
import '../../../app/widgets/states/error_state.dart';
import '../../../app/widgets/states/not_found_state.dart';
import '../../../app/widgets/states/progress_button.dart';
import '../../../app/widgets/states/screen_skeletons.dart';
import '../../../core/error/failure_mapper.dart';
import '../../../core/error/result.dart';
import '../../../core/logging/app_logger.dart';
import '../data/loss_repository.dart';
import '../domain/batch_rules.dart';
import '../domain/calendar_date.dart';
import '../domain/loss_record.dart';
import 'batch_actions.dart';
import 'batch_labels.dart';
import 'batch_providers.dart';
import 'date_choice.dart';

class LossFormResult {
  const LossFormResult({required this.lossId, required this.edited});

  final String lossId;
  final bool edited;
}

/// Records a new loss, or edits one when [lossId] is set.
class LossFormScreen extends ConsumerStatefulWidget {
  const LossFormScreen({required this.batchId, this.lossId, super.key});

  final String batchId;
  final String? lossId;

  @override
  ConsumerState<LossFormScreen> createState() => _LossFormScreenState();
}

class _LossFormScreenState extends ConsumerState<LossFormScreen> {
  final _countCtrl = TextEditingController(text: '1');
  final _notesCtrl = TextEditingController();
  var _kind = LossKind.died;
  SuspectedCause? _cause;
  CalendarDate? _date;
  var _seeded = false;
  var _dirty = false;
  String? _savedId;
  Timer? _repeat;

  bool get _isEdit => widget.lossId != null;
  String get _draftKey => 'mortality:new:${widget.batchId}';
  int get _count => int.tryParse(_countCtrl.text.trim()) ?? 0;

  @override
  void initState() {
    super.initState();
    if (!_isEdit) {
      _restoreDraft();
    }
  }

  @override
  void dispose() {
    _repeat?.cancel();
    _countCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _restoreDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_draftKey);
      if (raw == null || !mounted) {
        return;
      }
      final map = jsonDecode(raw) as Map<String, dynamic>;
      setState(() {
        _countCtrl.text = '${map['count'] ?? 1}';
        _kind = LossKind.fromStorage(map['kind'] as String?);
        _cause = SuspectedCause.fromStorage(map['cause'] as String?);
        final date = map['date'] as String?;
        _date = date == null ? null : CalendarDate.parseIso(date);
        _notesCtrl.text = map['notes'] as String? ?? '';
        _seeded = true;
      });
    } catch (error) {
      appLogger.w('Ignoring unreadable loss draft', error: error);
    }
  }

  void _changed() {
    _dirty = true;
    if (!_isEdit) {
      unawaited(_saveDraft());
    }
  }

  Future<void> _saveDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _draftKey,
      jsonEncode({
        'count': _count,
        'kind': _kind.storage,
        'cause': _cause?.storage,
        'date': _date?.toIso(),
        'notes': _notesCtrl.text,
      }),
    );
  }

  Future<void> _clearDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_draftKey);
  }

  void _seedFrom(LossEntry? existing) {
    if (_seeded) {
      return;
    }
    _seeded = true;
    if (existing == null) {
      return;
    }
    _countCtrl.text = '${existing.count}';
    _kind = existing.kind;
    _cause = existing.suspectedCause;
    _date = existing.occurredOn;
    _notesCtrl.text = existing.notes ?? '';
  }

  void _bump(int delta, int max) {
    final next = (_count + delta).clamp(1, max < 1 ? 1 : max);
    if (next == _count) {
      return;
    }
    AppHaptics.selection();
    setState(() => _countCtrl.text = '$next');
    _changed();
  }

  void _startRepeat(int delta, int max) {
    _repeat?.cancel();
    _repeat = Timer.periodic(
      const Duration(milliseconds: 90),
      (_) => _bump(delta, max),
    );
  }

  void _stopRepeat() {
    _repeat?.cancel();
    _repeat = null;
  }

  Future<bool> _save(CalendarDate today) async {
    final draft = LossDraft(
      count: _count,
      kind: _kind,
      occurredOn: _date ?? today,
      suspectedCause: _cause,
      notes: _notesCtrl.text,
    );
    final management = ref.read(batchManagementProvider);
    final afterWrite = afterBatchWrite(ref);
    final result = _isEdit
        ? await management.editLoss(lossId: widget.lossId!, draft: draft)
        : await management.recordLoss(batchId: widget.batchId, draft: draft);
    if (!mounted) {
      return false;
    }
    switch (result) {
      case Success(:final value):
        setState(() {
          _savedId = value.id;
          _dirty = false;
        });
        if (!_isEdit) {
          await _clearDraft();
        }
        afterWrite();
        AppHaptics.success();
        return true;
      case Error(:final failure):
        AppSnack.error(context, failureText(failure));
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewAsync = ref.watch(batchViewProvider(widget.batchId));
    final today = ref.watch(todayDateProvider);
    final permissions = ref.watch(batchPermissionsProvider);
    final view = viewAsync.value;

    LossEntry? existing;
    if (_isEdit && view != null) {
      for (final loss in view.losses) {
        if (loss.id == widget.lossId) {
          existing = loss;
        }
      }
    }
    final ready = view != null && (!_isEdit || existing != null);
    if (ready) {
      _seedFrom(existing);
    }

    final date = _date ?? today;
    final violation = ready
        ? LossRules.check(
            batch: view.facts,
            metrics: view.metrics,
            count: _count,
            occurredOn: date,
            today: today,
            replacing: existing,
          )
        : null;
    final blocked = permissions.recordLossBlockedReason;
    final canSave = ready && violation == null && blocked == null;

    return DiscardChangesScope(
      isDirty: _isEdit && _dirty,
      child: AppPage(
        title: _isEdit ? 'Edit loss' : 'Record loss',
        preset: PageLayout.form,
        scroll: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Close',
          onPressed: () => context.pop(),
        ),
        bottom: ready
            ? StickyActionBar(
                child: ProgressButton(
                  label: _isEdit ? 'Save changes' : 'Save loss',
                  busyLabel: 'Saving…',
                  onPressed: canSave ? () => _save(today) : null,
                  onSuccess: () => context.pop(
                    LossFormResult(lossId: _savedId!, edited: _isEdit),
                  ),
                ),
              )
            : null,
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
            if (data == null || (_isEdit && existing == null)) {
              return NotFoundState(onBack: () => context.pop());
            }
            final replacing = existing?.count ?? 0;
            final max = LossRules.maxCount(
              metrics: data.metrics,
              replacing: existing,
            );
            final firstDate = data.facts.acquiredOn;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  data.batch.name,
                  style: context.text.titleMedium?.copyWith(
                    color: context.scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                if (blocked != null || violation?.field == RuleField.batch) ...[
                  InlineBanner(
                    message: blocked ?? violation!.message,
                    icon: Icons.lock_outline,
                    tone: BannerTone.info,
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                _LivePreview(
                  before: data.metrics.liveCount,
                  after: data.metrics.liveAfter(_count - replacing),
                ),
                const SizedBox(height: AppSpacing.lg),
                AdaptiveForm(
                  children: [
                    _Section(
                      title: 'Number of birds',
                      error: violation?.field == RuleField.count
                          ? violation!.message
                          : null,
                      child: _CountStepper(
                        controller: _countCtrl,
                        onMinus: () => _bump(-1, max),
                        onPlus: () => _bump(1, max),
                        onHoldMinus: () => _startRepeat(-1, max),
                        onHoldPlus: () => _startRepeat(1, max),
                        onRelease: _stopRepeat,
                        onChanged: (_) {
                          setState(() {});
                          _changed();
                        },
                      ),
                    ),
                    _Section(
                      title: 'Date',
                      error: violation?.field == RuleField.occurredOn
                          ? violation!.message
                          : null,
                      child: DateChoice(
                        value: date,
                        today: today,
                        firstDate: firstDate,
                        onChanged: (day) {
                          setState(() => _date = day);
                          _changed();
                        },
                      ),
                    ),
                    _Section(
                      title: 'What happened?',
                      child: Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          for (final kind in LossKind.values)
                            ChoiceChip(
                              avatar: Icon(lossKindIcon(kind), size: 18),
                              label: Text(lossKindLabel(kind)),
                              selected: _kind == kind,
                              onSelected: (_) {
                                setState(() => _kind = kind);
                                _changed();
                              },
                            ),
                        ],
                      ),
                    ),
                    _Section(
                      title: 'What do you think happened? (optional)',
                      child: Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          for (final cause in SuspectedCause.values)
                            FilterChip(
                              label: Text(causeLabel(cause)),
                              selected: _cause == cause,
                              onSelected: (selected) {
                                setState(
                                  () => _cause = selected ? cause : null,
                                );
                                _changed();
                              },
                            ),
                        ],
                      ),
                    ),
                    TextField(
                      controller: _notesCtrl,
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: 'Notes (optional)',
                      ),
                      onChanged: (_) => _changed(),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _LivePreview extends StatelessWidget {
  const _LivePreview({required this.before, required this.after});

  final int before;
  final int after;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final text = 'Live birds: ${formatCount(before)} → ${formatCount(after)}';
    return Semantics(
      liveRegion: true,
      label: text,
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.pets_outlined, color: scheme.onSurfaceVariant),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                text,
                style: context.text.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child, this.error});

  final String title;
  final Widget child;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: context.text.titleSmall),
        const SizedBox(height: AppSpacing.sm),
        child,
        if (error != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            error!,
            style: context.text.bodySmall?.copyWith(
              color: context.scheme.error,
            ),
          ),
        ],
      ],
    );
  }
}

class _CountStepper extends StatelessWidget {
  const _CountStepper({
    required this.controller,
    required this.onMinus,
    required this.onPlus,
    required this.onHoldMinus,
    required this.onHoldPlus,
    required this.onRelease,
    required this.onChanged,
  });

  final TextEditingController controller;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  final VoidCallback onHoldMinus;
  final VoidCallback onHoldPlus;
  final VoidCallback onRelease;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _HoldButton(
          icon: Icons.remove,
          tooltip: 'One fewer',
          onTap: onMinus,
          onHold: onHoldMinus,
          onRelease: onRelease,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Semantics(
            label: 'Number of birds',
            child: TextField(
              controller: controller,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              style: context.text.headlineSmall,
              onChanged: onChanged,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        _HoldButton(
          icon: Icons.add,
          tooltip: 'One more',
          onTap: onPlus,
          onHold: onHoldPlus,
          onRelease: onRelease,
        ),
      ],
    );
  }
}

/// Tap for one step; press and hold to keep stepping.
class _HoldButton extends StatelessWidget {
  const _HoldButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    required this.onHold,
    required this.onRelease,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final VoidCallback onHold;
  final VoidCallback onRelease;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (_) => onHold(),
      onLongPressEnd: (_) => onRelease(),
      onLongPressCancel: onRelease,
      child: IconButton.filledTonal(
        iconSize: 28,
        constraints: const BoxConstraints(minWidth: 56, minHeight: 56),
        tooltip: tooltip,
        onPressed: onTap,
        icon: Icon(icon),
      ),
    );
  }
}
