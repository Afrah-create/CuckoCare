import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/time/kampala_today.dart';
import '../../../app/layout/content_frame.dart';
import '../../../app/layout/two_pane.dart';
import '../../../app/layout/layout_scope.dart';
import '../../../app/router/routes/typed_routes.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../../app/widgets/app_text_field.dart';
import '../../../app/widgets/inline_banner.dart';
import '../domain/batch_planner.dart';
import '../domain/programme_resolver.dart';
import 'batch_new_controller.dart';
import '../presentation/programme_catalog_provider.dart';

class BatchNewScreen extends ConsumerStatefulWidget {
  const BatchNewScreen({super.key});

  @override
  ConsumerState<BatchNewScreen> createState() => _BatchNewScreenState();
}

class _BatchNewScreenState extends ConsumerState<BatchNewScreen> {
  final _nameController = TextEditingController();
  final _countController = TextEditingController(text: '100');
  final _sourceController = TextEditingController();
  final _notesController = TextEditingController();
  final _farmNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _countController.dispose();
    _sourceController.dispose();
    _notesController.dispose();
    _farmNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catalogAsync = ref.watch(programmeCatalogProvider);
    final draft = ref.watch(batchNewControllerProvider);
    final ctrl = ref.read(batchNewControllerProvider.notifier);
    final layout = context.layout;

    if (_nameController.text.isEmpty && draft.name.isNotEmpty) {
      _nameController.text = draft.name;
    }

    final showActions = catalogAsync.hasValue;

    return Scaffold(
      appBar: AppBar(
        title: Text(_titleForStep(draft.wizardStep)),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: draft.isSubmitting ? null : () => context.pop(),
        ),
      ),
      bottomNavigationBar:
          showActions ? _bottomBar(draft, ctrl) : null,
      body: catalogAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => ContentFrame(
          child: InlineBanner(
            message:
                'Could not load the vaccination schedule. Check your app install and try again.',
            icon: Icons.error_outline,
          ),
        ),
        data: (catalog) {
          final isDraftSchedule = catalog.isDraft;
          final body = switch (draft.wizardStep) {
            BatchWizardStep.farm => _farmStep(draft, ctrl),
            BatchWizardStep.details => _detailsStep(draft, ctrl, layout),
            BatchWizardStep.review => _reviewStep(
                draft,
                ctrl,
                layout,
                isDraftSchedule,
              ),
          };

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _WizardStepBar(
                step: draft.wizardStep,
                showFarmStep: draft.needsFarmStep,
              ),
              if (draft.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.sm,
                    AppSpacing.md,
                    0,
                  ),
                  child: InlineBanner(
                    message: draft.errorMessage!,
                    icon: Icons.info_outline,
                  ),
                ),
              Expanded(child: body),
            ],
          );
        },
      ),
    );
  }

  String _titleForStep(BatchWizardStep step) => switch (step) {
        BatchWizardStep.farm => 'Name your farm',
        BatchWizardStep.details => 'New batch',
        BatchWizardStep.review => 'Review schedule',
      };

  Widget _farmStep(BatchNewState draft, BatchNewController ctrl) {
    return ContentFrame(
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            Text(
              'Before you add birds, give your farm a name. You can add district and phone later in settings.',
              style: context.text.bodyMedium?.copyWith(
                color: context.scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              controller: _farmNameController
                ..text = draft.farmName.isEmpty ? _farmNameController.text : draft.farmName,
              label: 'Farm name',
              leadingIcon: Icons.agriculture_outlined,
              exampleHint: 'e.g. Kira Poultry',
              textCapitalization: TextCapitalization.words,
              onEditingComplete: () => ctrl.setFarmName(_farmNameController.text),
              validator: (v) =>
                  (v == null || v.trim().length < 2) ? 'Required' : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailsStep(
    BatchNewState draft,
    BatchNewController ctrl,
    dynamic layout,
  ) {
    return ContentFrame(
      child: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.only(bottom: ContentFrame.scrollBottomInset(context)),
          children: [
            Text(
              'What kind of birds are you raising?',
              style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.sm),
            _SectionCard(
              title: 'Bird type',
              child: _BirdTypePicker(
                selected: draft.birdType,
                onSelected: ctrl.setBirdType,
              ),
            ),
            if (draft.birdType == BirdType.dualPurpose) ...[
              const SizedBox(height: AppSpacing.md),
              _SectionCard(
                title: 'Raised mainly for',
                child: Wrap(
                  spacing: AppSpacing.sm,
                  children: [
                    ChoiceChip(
                      label: const Text('Eggs'),
                      selected:
                          (draft.productionType ?? ProductionType.egg) ==
                              ProductionType.egg,
                      onSelected: (_) =>
                          ctrl.setProductionType(ProductionType.egg),
                    ),
                    ChoiceChip(
                      label: const Text('Meat'),
                      selected: draft.productionType == ProductionType.meat,
                      onSelected: (_) =>
                          ctrl.setProductionType(ProductionType.meat),
                    ),
                  ],
                ),
              ),
            ],
            if (draft.birdType == BirdType.local) ...[
              const SizedBox(height: AppSpacing.md),
              const _NoticePanel(
                text:
                    'Local breeds are not scheduled automatically yet. You can still register the flock and add reminders yourself.',
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            _SectionCard(
              title: 'Batch details',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
            AppTextField(
              controller: _nameController,
              label: 'Batch name',
              leadingIcon: Icons.label_outline,
              textCapitalization: TextCapitalization.words,
              onEditingComplete: () =>
                  ctrl.updateDetails(name: _nameController.text),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _countController,
              label: 'Number of birds',
              leadingIcon: Icons.numbers,
              keyboardType: TextInputType.number,
              onEditingComplete: () => ctrl.updateDetails(
                initialCount: int.tryParse(_countController.text) ?? draft.initialCount,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Date you received the birds'),
              subtitle: Text(
                draft.acquiredOn == null
                    ? 'Pick a date'
                    : DateFormat.yMMMd().format(draft.acquiredOn!),
              ),
              trailing: const Icon(Icons.calendar_today_outlined),
              onTap: () async {
                final today = ref.read(kampalaTodayProvider);
                final picked = await showDatePicker(
                  context: context,
                  initialDate: draft.acquiredOn ?? today,
                  firstDate: today.subtract(const Duration(days: 365 * 2)),
                  lastDate: today,
                );
                if (picked != null) {
                  ctrl.updateDetails(acquiredOn: picked);
                }
              },
            ),
            const Divider(height: AppSpacing.lg),
            Text(
              'Bird age (day 1 = hatch day)',
              style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [1, 7, 14, 21, 28].map((age) {
                final selected = !draft.useHatchDate && draft.ageAtAcquisition == age;
                return FilterChip(
                  label: Text('Day $age'),
                  selected: selected,
                  onSelected: (_) => ctrl.updateDetails(
                    useHatchDate: false,
                    ageAtAcquisition: age,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.sm),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: const Text('I know the hatch date'),
              value: draft.useHatchDate,
              onChanged: (v) => ctrl.updateDetails(useHatchDate: v ?? false),
            ),
            if (draft.useHatchDate)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Hatch date'),
                subtitle: Text(
                  draft.hatchDate == null
                      ? 'Pick hatch date'
                      : DateFormat.yMMMd().format(draft.hatchDate!),
                ),
                trailing: const Icon(Icons.cake_outlined),
                onTap: () async {
                  final today = ref.read(kampalaTodayProvider);
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: draft.hatchDate ?? today,
                    firstDate: today.subtract(const Duration(days: 365 * 3)),
                    lastDate: today,
                  );
                  if (picked != null) {
                    ctrl.updateDetails(hatchDate: picked);
                  }
                },
              )
            else
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Age in days'),
                subtitle: Slider(
                  value: draft.ageAtAcquisition.clamp(1, 120).toDouble(),
                  min: 1,
                  max: 120,
                  divisions: 119,
                  label: 'Day ${draft.ageAtAcquisition}',
                  onChanged: (v) => ctrl.updateDetails(
                    ageAtAcquisition: v.round(),
                  ),
                ),
              ),
            if (draft.ageAtAcquisition > 1 &&
                draft.birdType != BirdType.local) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                'Vaccinated at the hatchery?',
                style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.sm,
                children: [
                  ChoiceChip(
                    label: const Text('Yes'),
                    selected:
                        draft.hatcheryAnswer == HatcheryVaccinationAnswer.yes,
                    onSelected: (_) => ctrl.updateDetails(
                      hatcheryAnswer: HatcheryVaccinationAnswer.yes,
                    ),
                  ),
                  ChoiceChip(
                    label: const Text('No'),
                    selected:
                        draft.hatcheryAnswer == HatcheryVaccinationAnswer.no,
                    onSelected: (_) => ctrl.updateDetails(
                      hatcheryAnswer: HatcheryVaccinationAnswer.no,
                    ),
                  ),
                  ChoiceChip(
                    label: const Text('Not sure'),
                    selected: draft.hatcheryAnswer ==
                        HatcheryVaccinationAnswer.notSure,
                    onSelected: (_) => ctrl.updateDetails(
                      hatcheryAnswer: HatcheryVaccinationAnswer.notSure,
                    ),
                  ),
                ],
              ),
            ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _sourceController,
              label: 'Source / hatchery (optional)',
              leadingIcon: Icons.store_outlined,
              textCapitalization: TextCapitalization.words,
              onEditingComplete: () =>
                  ctrl.updateDetails(sourceName: _sourceController.text),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _notesController,
              label: 'Notes (optional)',
              leadingIcon: Icons.notes_outlined,
              textCapitalization: TextCapitalization.sentences,
              onEditingComplete: () =>
                  ctrl.updateDetails(notes: _notesController.text),
            ),
          ],
        ),
      ),
    );
  }

  Widget _reviewStep(
    BatchNewState draft,
    BatchNewController ctrl,
    dynamic layout,
    bool isDraftSchedule,
  ) {
    final plan = draft.preview;
    final timeline = plan == null
        ? const Center(child: CircularProgressIndicator())
        : _SchedulePreview(plan: plan, onToggle: ctrl.setStepEnabled);

    final summary = _ReviewSummary(draft: draft);

    final sidebar = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        summary,
        const SizedBox(height: AppSpacing.md),
        if (isDraftSchedule) ...[
          const _NoticePanel(
            text:
                'This schedule is still in draft. Check with your vet before relying on it.',
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        const _NoticePanel(
          text:
              'This app gives guidance only. Always confirm vaccines and timing with a vet or poultry specialist.',
        ),
        const SizedBox(height: AppSpacing.md),
        _SectionCard(
          title: 'What to include',
          child: Column(
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Recommended steps'),
                subtitle: const Text('Included by default'),
                value: draft.includeRecommended,
                onChanged: ctrl.setIncludeRecommended,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Optional steps'),
                subtitle: const Text('Add extra steps if you want them'),
                value: draft.includeOptional,
                onChanged: ctrl.setIncludeOptional,
              ),
            ],
          ),
        ),
      ],
    );

    if (layout.useTwoPane) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: layout.margin),
        child: TwoPane(
          primary: SingleChildScrollView(child: sidebar),
          secondary: timeline,
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.fromLTRB(
        layout.margin,
        0,
        layout.margin,
        ContentFrame.scrollBottomInset(context),
      ),
      children: [
        sidebar,
        const SizedBox(height: AppSpacing.md),
        Text(
          'Upcoming tasks',
          style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.sm),
        timeline,
      ],
    );
  }

  Widget _bottomBar(BatchNewState draft, BatchNewController ctrl) {
    final showBack = draft.wizardStep != BatchWizardStep.farm &&
        !(draft.wizardStep == BatchWizardStep.details && !draft.needsFarmStep);
    // bottomNavigationBar can receive unbounded max width on some devices.
    final barWidth = MediaQuery.sizeOf(context).width;

    return ColoredBox(
      color: context.scheme.surfaceContainerLow,
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: barWidth,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.md,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (showBack)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: draft.isSubmitting ? null : ctrl.goBack,
                      child: const Text('Back'),
                    ),
                  ),
                FilledButton(
                  onPressed: draft.isSubmitting
                      ? null
                      : () => _onPrimary(draft, ctrl),
                  child: draft.isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_primaryLabel(draft)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _primaryLabel(BatchNewState draft) => switch (draft.wizardStep) {
        BatchWizardStep.farm => 'Continue',
        BatchWizardStep.details => 'Preview schedule',
        BatchWizardStep.review => 'Create batch',
      };

  Future<void> _onPrimary(BatchNewState draft, BatchNewController ctrl) async {
    switch (draft.wizardStep) {
      case BatchWizardStep.farm:
        ctrl.setFarmName(_farmNameController.text);
        if (!ctrl.validateFarmStep()) {
          return;
        }
        ctrl.goToDetails();
      case BatchWizardStep.details:
        ctrl.updateDetails(
          name: _nameController.text,
          initialCount: int.tryParse(_countController.text) ?? draft.initialCount,
          sourceName: _sourceController.text,
          notes: _notesController.text,
        );
        if (!ctrl.validateDetailsStep()) {
          return;
        }
        ctrl.goToReview();
      case BatchWizardStep.review:
        final id = await ctrl.submit();
        if (id != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Batch saved on this device')),
          );
          context.pop();
          BatchDetailRoute(batchId: id).push(context);
        }
    }
  }
}

class _WizardStepBar extends StatelessWidget {
  const _WizardStepBar({required this.step, required this.showFarmStep});

  final BatchWizardStep step;
  final bool showFarmStep;

  @override
  Widget build(BuildContext context) {
    final labels = showFarmStep
        ? const ['Farm', 'Batch', 'Review']
        : const ['Batch', 'Review'];
    final index = showFarmStep
        ? step.index
        : step == BatchWizardStep.review
            ? 1
            : 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      child: Row(
        children: List.generate(labels.length * 2 - 1, (i) {
          if (i.isOdd) {
            final stepIndex = i ~/ 2;
            final done = stepIndex < index;
            return Expanded(
              child: Container(
                height: 2,
                color: done
                    ? context.scheme.primary
                    : context.scheme.outlineVariant,
              ),
            );
          }
          final stepIndex = i ~/ 2;
          final active = stepIndex == index;
          final done = stepIndex < index;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: done || active
                    ? context.scheme.primary
                    : context.scheme.surfaceContainerHighest,
                child: Text(
                  '${stepIndex + 1}',
                  style: context.text.labelSmall?.copyWith(
                    color: done || active
                        ? context.scheme.onPrimary
                        : context.scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                labels[stepIndex],
                style: context.text.labelSmall?.copyWith(
                  color: active
                      ? context.scheme.onSurface
                      : context.scheme.onSurfaceVariant,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: context.text.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            child,
          ],
        ),
      ),
    );
  }
}

class _NoticePanel extends StatelessWidget {
  const _NoticePanel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: context.text.bodyMedium?.copyWith(
          color: context.scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _BirdTypePicker extends StatelessWidget {
  const _BirdTypePicker({required this.selected, required this.onSelected});

  final BirdType selected;
  final ValueChanged<BirdType> onSelected;

  static const _options = [
    (BirdType.broiler, 'Broiler', 'Meat birds'),
    (BirdType.layer, 'Layer', 'Eggs'),
    (BirdType.dualPurpose, 'Dual-purpose', 'Eggs and meat'),
    (BirdType.local, 'Local / village', 'No auto schedule'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _options.map((o) {
        return RadioListTile<BirdType>(
          contentPadding: EdgeInsets.zero,
          value: o.$1,
          groupValue: selected,
          onChanged: (v) {
            if (v != null) {
              onSelected(v);
            }
          },
          title: Text(o.$2),
          subtitle: Text(o.$3),
        );
      }).toList(),
    );
  }
}

class _ReviewSummary extends StatelessWidget {
  const _ReviewSummary({required this.draft});

  final BatchNewState draft;

  @override
  Widget build(BuildContext context) {
    final acquired = draft.acquiredOn == null
        ? '—'
        : DateFormat.yMMMd().format(draft.acquiredOn!);
    final bird = switch (draft.birdType) {
      BirdType.broiler => 'Broiler',
      BirdType.layer => 'Layer',
      BirdType.dualPurpose => 'Dual-purpose',
      BirdType.local => 'Local',
    };

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              draft.name.isEmpty ? 'New batch' : draft.name,
              style: context.text.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '$bird · ${draft.initialCount} birds · Received $acquired',
              style: context.text.bodyMedium?.copyWith(
                color: context.scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SchedulePreview extends StatelessWidget {
  const _SchedulePreview({required this.plan, required this.onToggle});

  final BatchPlan plan;
  final void Function(String stepId, bool enabled) onToggle;

  @override
  Widget build(BuildContext context) {
    if (plan.tasks.isEmpty) {
      return Center(
        child: Text(
          plan.programmeKey == null
              ? 'No automatic schedule for this type.'
              : 'No tasks in preview.',
          textAlign: TextAlign.center,
        ),
      );
    }

    final fmt = DateFormat.MMMd();
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: plan.tasks.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.xs),
      itemBuilder: (context, index) {
        final task = plan.tasks[index];
        final label = _labelFromSnapshot(task.stepSnapshotJson);
        final due = fmt.format(
          DateTime(task.dueOn.year, task.dueOn.month, task.dueOn.day),
        );
        return Card(
          margin: EdgeInsets.zero,
          child: ListTile(
            leading: Icon(_iconFor(task.status)),
            title: Text(label),
            subtitle: Text(
              '$due · ${_statusLabel(task.status)}'
              '${task.shiftedFrom != null ? ' · moved' : ''}',
            ),
            trailing: !task.enabled
                ? TextButton(
                    onPressed: () => onToggle(task.stepId, true),
                    child: const Text('Include'),
                  )
                : null,
          ),
        );
      },
    );
  }

  String _labelFromSnapshot(String raw) {
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return map['label'] as String? ?? 'Task';
    } catch (_) {
      return 'Task';
    }
  }

  IconData _iconFor(PlannedTaskStatus status) => switch (status) {
        PlannedTaskStatus.done => Icons.check_circle_outline,
        PlannedTaskStatus.skipped => Icons.block,
        PlannedTaskStatus.assumedDone => Icons.help_outline,
        PlannedTaskStatus.pending => Icons.event_outlined,
      };

  String _statusLabel(PlannedTaskStatus status) => switch (status) {
        PlannedTaskStatus.done => 'Done',
        PlannedTaskStatus.skipped => 'Skipped',
        PlannedTaskStatus.assumedDone => 'Confirm later',
        PlannedTaskStatus.pending => 'Scheduled',
      };
}
