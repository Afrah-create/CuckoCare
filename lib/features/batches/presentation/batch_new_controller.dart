import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../app/di/providers.dart';
import '../../../core/time/kampala_today.dart';
import '../../../core/utils/uuid_v7.dart';
import '../../notifications/presentation/notification_prefs_provider.dart';
import '../data/batch_repository.dart';
import '../domain/batch_planner.dart';
import '../domain/calendar_date.dart';
import '../domain/programme_resolver.dart';
import '../presentation/programme_catalog_provider.dart';

enum BatchWizardStep { farm, details, review }

class BatchNewState {
  const BatchNewState({
    this.wizardStep = BatchWizardStep.details,
    this.needsFarmStep = false,
    this.farmName = '',
    this.birdType = BirdType.layer,
    this.productionType,
    this.name = '',
    this.initialCount = 100,
    this.acquiredOn,
    this.ageAtAcquisition = 1,
    this.useHatchDate = false,
    this.hatchDate,
    this.hatcheryAnswer = HatcheryVaccinationAnswer.notSure,
    this.sourceName = '',
    this.notes = '',
    this.includeRecommended = true,
    this.includeOptional = false,
    this.stepEnabledOverrides = const {},
    this.preview,
    this.isSubmitting = false,
    this.errorMessage,
    this.batchId = '',
  });

  final BatchWizardStep wizardStep;
  final bool needsFarmStep;
  final String farmName;
  final BirdType birdType;
  final ProductionType? productionType;
  final String name;
  final int initialCount;
  final DateTime? acquiredOn;
  final int ageAtAcquisition;
  final bool useHatchDate;
  final DateTime? hatchDate;
  final HatcheryVaccinationAnswer hatcheryAnswer;
  final String sourceName;
  final String notes;
  final bool includeRecommended;
  final bool includeOptional;
  final Map<String, bool> stepEnabledOverrides;
  final BatchPlan? preview;
  final bool isSubmitting;
  final String? errorMessage;
  final String batchId;

  BatchNewState copyWith({
    BatchWizardStep? wizardStep,
    bool? needsFarmStep,
    String? farmName,
    BirdType? birdType,
    ProductionType? productionType,
    String? name,
    int? initialCount,
    DateTime? acquiredOn,
    int? ageAtAcquisition,
    bool? useHatchDate,
    DateTime? hatchDate,
    HatcheryVaccinationAnswer? hatcheryAnswer,
    String? sourceName,
    String? notes,
    bool? includeRecommended,
    bool? includeOptional,
    Map<String, bool>? stepEnabledOverrides,
    BatchPlan? preview,
    bool? isSubmitting,
    String? errorMessage,
    String? batchId,
    bool clearError = false,
  }) {
    return BatchNewState(
      wizardStep: wizardStep ?? this.wizardStep,
      needsFarmStep: needsFarmStep ?? this.needsFarmStep,
      farmName: farmName ?? this.farmName,
      birdType: birdType ?? this.birdType,
      productionType: productionType ?? this.productionType,
      name: name ?? this.name,
      initialCount: initialCount ?? this.initialCount,
      acquiredOn: acquiredOn ?? this.acquiredOn,
      ageAtAcquisition: ageAtAcquisition ?? this.ageAtAcquisition,
      useHatchDate: useHatchDate ?? this.useHatchDate,
      hatchDate: hatchDate ?? this.hatchDate,
      hatcheryAnswer: hatcheryAnswer ?? this.hatcheryAnswer,
      sourceName: sourceName ?? this.sourceName,
      notes: notes ?? this.notes,
      includeRecommended: includeRecommended ?? this.includeRecommended,
      includeOptional: includeOptional ?? this.includeOptional,
      stepEnabledOverrides: stepEnabledOverrides ?? this.stepEnabledOverrides,
      preview: preview ?? this.preview,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      batchId: batchId ?? this.batchId,
    );
  }
}

final batchNewControllerProvider =
    NotifierProvider<BatchNewController, BatchNewState>(
  BatchNewController.new,
);

class BatchNewController extends Notifier<BatchNewState> {
  static const _draftKey = 'draft:batch:new';
  var _bootstrapped = false;
  String? _batchId;

  @override
  BatchNewState build() {
    ref.keepAlive();
    final farm = ref.watch(primaryFarmProvider).value;
    final today = ref.watch(kampalaTodayProvider);
    final needsFarm = farm == null;
    _batchId ??= newId();
    final batchId = _batchId!;
    final defaultName = _defaultBatchName(today, BirdType.layer);

    if (!_bootstrapped) {
      _bootstrapped = true;
      Future.microtask(() => _restoreDraft(
            needsFarm: needsFarm,
            today: today,
            defaultName: defaultName,
            batchId: batchId,
          ));
    }

    ref.listen(programmeCatalogProvider, (_, next) {
      if (next.hasValue) {
        _refreshPreview();
      }
    });

    return BatchNewState(
      needsFarmStep: needsFarm,
      wizardStep: needsFarm ? BatchWizardStep.farm : BatchWizardStep.details,
      acquiredOn: today,
      name: defaultName,
      batchId: batchId,
    );
  }

  void _startNextBatch() {
    _batchId = newId();
    final today = ref.read(kampalaTodayProvider);
    final farm = ref.read(primaryFarmProvider).value;
    final needsFarm = farm == null;
    state = BatchNewState(
      needsFarmStep: needsFarm,
      wizardStep: needsFarm ? BatchWizardStep.farm : BatchWizardStep.details,
      farmName: farm?.name ?? state.farmName,
      acquiredOn: today,
      name: _defaultBatchName(today, BirdType.layer),
      batchId: _batchId!,
    );
  }

  String _defaultBatchName(DateTime today, BirdType type) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final label = switch (type) {
      BirdType.broiler => 'Broilers',
      BirdType.layer => 'Layers',
      BirdType.dualPurpose => 'Dual-purpose',
      BirdType.local => 'Local flock',
    };
    return '$label - ${today.day} ${months[today.month - 1]} ${today.year}';
  }

  Future<void> _restoreDraft({
    required bool needsFarm,
    required DateTime today,
    required String defaultName,
    required String batchId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_draftKey);
    if (raw == null) {
      _refreshPreview();
      return;
    }
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      state = BatchNewState(
        wizardStep: needsFarm
            ? BatchWizardStep.farm
            : BatchWizardStep.values.byName(
                map['wizard_step'] as String? ?? 'details',
              ),
        needsFarmStep: needsFarm,
        farmName: map['farm_name'] as String? ?? '',
        birdType: BirdType.values.byName(map['bird_type'] as String? ?? 'layer'),
        productionType: map['production_type'] == null
            ? null
            : ProductionType.values.byName(map['production_type'] as String),
        name: map['name'] as String? ?? defaultName,
        initialCount: map['initial_count'] as int? ?? 100,
        acquiredOn: map['acquired_on'] == null
            ? today
            : DateTime.parse(map['acquired_on'] as String),
        ageAtAcquisition: map['age_at_acquisition'] as int? ?? 1,
        useHatchDate: map['use_hatch_date'] as bool? ?? false,
        hatchDate: map['hatch_date'] == null
            ? null
            : DateTime.parse(map['hatch_date'] as String),
        hatcheryAnswer: HatcheryVaccinationAnswer.values.byName(
          map['hatchery_answer'] as String? ?? 'notSure',
        ),
        sourceName: map['source_name'] as String? ?? '',
        notes: map['notes'] as String? ?? '',
        includeRecommended: map['include_recommended'] as bool? ?? true,
        includeOptional: map['include_optional'] as bool? ?? false,
        batchId: map['batch_id'] as String? ?? batchId,
      );
      _batchId = state.batchId;
    } catch (_) {
      // ignore corrupt draft
    }
    _refreshPreview();
  }

  Future<void> _persistDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final s = state;
    await prefs.setString(
      _draftKey,
      jsonEncode({
        'wizard_step': s.wizardStep.name,
        'farm_name': s.farmName,
        'bird_type': s.birdType.name,
        'production_type': s.productionType?.name,
        'name': s.name,
        'initial_count': s.initialCount,
        'acquired_on': s.acquiredOn?.toIso8601String(),
        'age_at_acquisition': s.ageAtAcquisition,
        'use_hatch_date': s.useHatchDate,
        'hatch_date': s.hatchDate?.toIso8601String(),
        'hatchery_answer': s.hatcheryAnswer.name,
        'source_name': s.sourceName,
        'notes': s.notes,
        'include_recommended': s.includeRecommended,
        'include_optional': s.includeOptional,
        'batch_id': s.batchId,
      }),
    );
  }

  void setFarmName(String value) {
    state = state.copyWith(farmName: value, clearError: true);
    _persistDraft();
  }

  void setBirdType(BirdType type) {
    final today = ref.read(kampalaTodayProvider);
    state = state.copyWith(
      birdType: type,
      name: _defaultBatchName(today, type),
      productionType: type == BirdType.dualPurpose ? ProductionType.egg : null,
      clearError: true,
    );
    _persistDraft();
    _refreshPreview();
  }

  void setProductionType(ProductionType type) {
    state = state.copyWith(productionType: type, clearError: true);
    _persistDraft();
    _refreshPreview();
  }

  void updateDetails({
    String? name,
    int? initialCount,
    DateTime? acquiredOn,
    int? ageAtAcquisition,
    bool? useHatchDate,
    DateTime? hatchDate,
    HatcheryVaccinationAnswer? hatcheryAnswer,
    String? sourceName,
    String? notes,
  }) {
    state = state.copyWith(
      name: name,
      initialCount: initialCount,
      acquiredOn: acquiredOn,
      ageAtAcquisition: ageAtAcquisition,
      useHatchDate: useHatchDate,
      hatchDate: hatchDate,
      hatcheryAnswer: hatcheryAnswer,
      sourceName: sourceName,
      notes: notes,
      clearError: true,
    );
    _persistDraft();
    _refreshPreview();
  }

  void setIncludeRecommended(bool value) {
    state = state.copyWith(includeRecommended: value, clearError: true);
    _persistDraft();
    _refreshPreview();
  }

  void setIncludeOptional(bool value) {
    state = state.copyWith(includeOptional: value, clearError: true);
    _persistDraft();
    _refreshPreview();
  }

  void setStepEnabled(String stepId, bool enabled) {
    final next = Map<String, bool>.from(state.stepEnabledOverrides)
      ..[stepId] = enabled;
    state = state.copyWith(stepEnabledOverrides: next, clearError: true);
    _persistDraft();
    _refreshPreview();
  }

  void goToDetails() {
    state = state.copyWith(wizardStep: BatchWizardStep.details, clearError: true);
  }

  void goToReview() {
    state = state.copyWith(wizardStep: BatchWizardStep.review, clearError: true);
    _refreshPreview();
  }

  void goBack() {
    if (state.wizardStep == BatchWizardStep.review) {
      state = state.copyWith(wizardStep: BatchWizardStep.details, clearError: true);
      return;
    }
    if (state.wizardStep == BatchWizardStep.details && state.needsFarmStep) {
      state = state.copyWith(wizardStep: BatchWizardStep.farm, clearError: true);
    }
  }

  void _refreshPreview() {
    final catalog = ref.read(programmeCatalogProvider).value;
    if (catalog == null) {
      return;
    }
    final input = _buildPlanInput();
    if (input == null) {
      return;
    }
    final today = CalendarDate.fromDateTime(ref.read(kampalaTodayProvider));
    const planner = BatchPlanner();
    final plan = planner.plan(
      input: input,
      catalog: catalog,
      options: BatchPlanOptions(
        includeRecommended: state.includeRecommended,
        includeOptional: state.includeOptional,
        hatcheryAnswer: state.hatcheryAnswer,
        stepEnabledOverrides: state.stepEnabledOverrides,
      ),
      today: today,
    );
    state = state.copyWith(preview: plan);
  }

  BatchPlanInput? _buildPlanInput() {
    final acquired = state.acquiredOn;
    if (acquired == null) {
      return null;
    }
    var age = state.ageAtAcquisition;
    if (state.useHatchDate && state.hatchDate != null) {
      final acquiredCal = CalendarDate.fromDateTime(acquired);
      final hatchCal = CalendarDate.fromDateTime(state.hatchDate!);
      age = hatchCal.daysUntil(acquiredCal) + 1;
      if (age < 1) {
        age = 1;
      }
    }
    return BatchPlanInput(
      batchId: state.batchId,
      farmId: 'pending',
      name: state.name.trim(),
      birdType: state.birdType,
      initialCount: state.initialCount,
      acquiredOn: CalendarDate.fromDateTime(acquired),
      ageAtAcquisitionDays: age,
      productionType: state.productionType,
      sourceName: state.sourceName.trim().isEmpty ? null : state.sourceName.trim(),
      notes: state.notes.trim().isEmpty ? null : state.notes.trim(),
    );
  }

  bool validateFarmStep() {
    if (state.farmName.trim().length < 2) {
      state = state.copyWith(errorMessage: 'Enter your farm name.');
      return false;
    }
    return true;
  }

  bool validateDetailsStep() {
    if (state.name.trim().length < 2) {
      state = state.copyWith(errorMessage: 'Give this batch a name.');
      return false;
    }
    if (state.initialCount < 1 || state.initialCount > 500000) {
      state = state.copyWith(errorMessage: 'Bird count must be between 1 and 500,000.');
      return false;
    }
    final today = ref.read(kampalaTodayProvider);
    final acquired = state.acquiredOn;
    if (acquired == null || acquired.isAfter(today)) {
      state = state.copyWith(errorMessage: 'Acquisition date cannot be in the future.');
      return false;
    }
    if (state.birdType == BirdType.dualPurpose && state.productionType == null) {
      state = state.copyWith(errorMessage: 'Choose egg or meat type.');
      return false;
    }
    return true;
  }

  Future<String?> submit() async {
    if (state.isSubmitting) {
      return null;
    }
    final catalog = await ref.read(programmeCatalogProvider.future);
    final input = _buildPlanInput();
    if (input == null) {
      state = state.copyWith(errorMessage: 'Complete the form first.');
      return null;
    }

    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      var farmId = ref.read(primaryFarmProvider).value?.id;
      if (farmId == null) {
        farmId = await ref.read(farmRepositoryProvider).ensureFarmNamed(state.farmName);
      }

      final today = CalendarDate.fromDateTime(ref.read(kampalaTodayProvider));
      const planner = BatchPlanner();
      final plan = planner.plan(
        input: BatchPlanInput(
          batchId: state.batchId,
          farmId: farmId,
          name: input.name,
          birdType: input.birdType,
          initialCount: input.initialCount,
          acquiredOn: input.acquiredOn,
          ageAtAcquisitionDays: input.ageAtAcquisitionDays,
          productionType: input.productionType,
          sourceName: input.sourceName,
          notes: input.notes,
        ),
        catalog: catalog,
        options: BatchPlanOptions(
          includeRecommended: state.includeRecommended,
          includeOptional: state.includeOptional,
          hatcheryAnswer: state.hatcheryAnswer,
          stepEnabledOverrides: state.stepEnabledOverrides,
        ),
        today: today,
      );

      if (plan.programmeKey == null &&
          input.birdType != BirdType.local &&
          plan.tasks.isEmpty) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: 'Could not build a schedule for this bird type.',
        );
        return null;
      }

      await ref.read(batchRepositoryProvider).createBatchWithSchedule(
            CreateBatchRequest(
              farmId: farmId,
              input: BatchPlanInput(
                batchId: state.batchId,
                farmId: farmId,
                name: input.name,
                birdType: input.birdType,
                initialCount: input.initialCount,
                acquiredOn: input.acquiredOn,
                ageAtAcquisitionDays: input.ageAtAcquisitionDays,
                productionType: input.productionType,
                sourceName: input.sourceName,
                notes: input.notes,
              ),
              plan: plan,
              catalog: catalog,
              hatcheryVaccinated: state.ageAtAcquisition > 1
                  ? switch (state.hatcheryAnswer) {
                      HatcheryVaccinationAnswer.yes => true,
                      HatcheryVaccinationAnswer.no => false,
                      HatcheryVaccinationAnswer.notSure => null,
                    }
                  : null,
              sourceName: input.sourceName,
              notes: input.notes,
              productionType: input.productionType?.name,
            ),
          );

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_draftKey);
      final savedId = state.batchId;
      _startNextBatch();
      ref.read(syncSchedulerProvider).notifyLocalWrite();
      ref.read(reminderReconcilerProvider).scheduleReconcile();
      return savedId;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Could not save batch. Your draft is kept — try again.',
      );
      return null;
    }
  }
}
