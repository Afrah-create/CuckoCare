import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/di/providers.dart';
import '../../../app/layout/layout_scope.dart';
import '../../../app/router/routes/typed_routes.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../../app/widgets/states/app_busy_indicator.dart';
import '../../../app/widgets/states/app_snack.dart';
import '../../../app/widgets/inline_banner.dart';
import '../../../app/widgets/states/skeleton.dart';
import '../../batches/presentation/batch_labels.dart';
import '../../batches/presentation/batch_providers.dart';
import '../../farms/domain/farm_profile.dart';
import '../../vet/presentation/vet_inbox_providers.dart';
import '../data/health_incident_photo_storage.dart';
import '../data/health_repository.dart';
import '../domain/incident_symptoms.dart';
import 'incident_media_permissions.dart';

Future<bool?> showReportHealthConcernSheet(
  BuildContext context, {
  required String batchId,
  required String farmId,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (ctx) =>
        _ReportHealthConcernSheet(batchId: batchId, farmId: farmId),
  );
}

class _ReportHealthConcernSheet extends ConsumerStatefulWidget {
  const _ReportHealthConcernSheet({
    required this.batchId,
    required this.farmId,
  });

  final String batchId;
  final String farmId;

  @override
  ConsumerState<_ReportHealthConcernSheet> createState() =>
      _ReportHealthConcernSheetState();
}

class _ReportHealthConcernSheetState
    extends ConsumerState<_ReportHealthConcernSheet> {
  final _summaryController = TextEditingController();
  final _notesController = TextEditingController();
  final _affectedController = TextEditingController();
  final _picker = ImagePicker();
  final _photoStorage = HealthIncidentPhotoStorage();

  bool _requestVet = true;
  String _serviceType = 'either';
  String? _requestedVetUserId;
  bool _saving = false;
  final Set<String> _symptoms = {};
  final List<String> _localPhotoPaths = [];

  static const _maxPhotos = 3;

  @override
  void dispose() {
    _summaryController.dispose();
    _notesController.dispose();
    _affectedController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto(ImageSource source) async {
    if (_localPhotoPaths.length >= _maxPhotos) {
      return;
    }
    final confirmed = source == ImageSource.camera
        ? await confirmIncidentCamera(context)
        : await confirmIncidentGallery(context);
    if (!confirmed || !mounted) {
      return;
    }
    try {
      final file = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        imageQuality: 85,
        requestFullMetadata: false,
      );
      if (file == null) {
        return;
      }
      final persisted = await _photoStorage.persistPickedFile(File(file.path));
      if (mounted) {
        setState(() => _localPhotoPaths.add(persisted));
      }
    } on PlatformException catch (e) {
      if (!mounted) {
        return;
      }
      final denied =
          e.code == 'camera_access_denied' ||
          e.code == 'photo_access_denied' ||
          e.code == 'permission_denied';
      AppSnack.show(
        context,
        message: denied
            ? 'Permission denied. Allow camera or photos in Settings, then try again.'
            : "Couldn't add that photo. Please try again.",
        kind: AppSnackKind.error,
      );
    } catch (_) {
      if (mounted) {
        AppSnack.error(context, "Couldn't add that photo. Please try again.");
      }
    }
  }

  Future<void> _submit() async {
    if (_saving) {
      return;
    }
    if (_summaryController.text.trim().isEmpty) {
      AppSnack.show(context, message: 'Please describe what you noticed.');
      return;
    }
    final affected = int.tryParse(_affectedController.text.trim());
    final live = ref
        .read(batchViewProvider(widget.batchId))
        .value
        ?.metrics
        .liveCount;
    if (affected != null && live != null && affected > live) {
      AppSnack.error(
        context,
        'You only have ${formatCount(live)} live birds in this batch.',
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await ref
          .read(healthRepositoryProvider)
          .reportConcern(
            ReportHealthConcernInput(
              batchId: widget.batchId,
              farmId: widget.farmId,
              summary: _summaryController.text,
              notes: _notesController.text,
              affectedBirdCount: affected,
              symptoms: _symptoms.toList(),
              localPhotoPaths: List.of(_localPhotoPaths),
              requestVet: _requestVet,
              serviceType: _serviceType,
              requestedVetUserId: _requestedVetUserId,
            ),
          );
      ref.read(syncSchedulerProvider).notifyLocalWrite();
      if (mounted) {
        final message = _requestVet
            ? 'Saved. The vet request will send when you are online.'
            : 'Saved';
        AppSnack.success(context, message);
        context.pop(true);
      }
    } catch (e) {
      if (mounted) {
        AppSnack.error(context, "Couldn't save. Please try again.");
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final sheetHeight = context.layout.size.height * 0.88;
    final farm = ref.watch(primaryFarmProvider).value;
    final hasGps = farmHasGps(farm);
    final vetsAsync = ref.watch(availableVetsProvider(widget.farmId));
    final online = ref.watch(connectivityOnlineProvider).value ?? true;
    final liveBirds = ref
        .watch(batchViewProvider(widget.batchId))
        .value
        ?.metrics
        .liveCount;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SizedBox(
        height: sheetHeight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xs,
                0,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: Row(
                children: [
                  TextButton(
                    onPressed: _saving ? null : () => context.pop(),
                    child: const Text('Cancel'),
                  ),
                  Expanded(
                    child: Text(
                      'Report incident',
                      textAlign: TextAlign.center,
                      style: context.text.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 72),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _summaryController,
                      decoration: const InputDecoration(
                        labelText: 'What did you notice?',
                        hintText: 'Coughing, deaths, low appetite…',
                      ),
                      maxLines: 2,
                      textCapitalization: TextCapitalization.sentences,
                      enabled: !_saving,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text('Symptoms', style: context.text.labelLarge),
                    const SizedBox(height: AppSpacing.xs),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final label in commonIncidentSymptoms)
                          FilterChip(
                            label: Text(label),
                            selected: _symptoms.contains(label),
                            onSelected: _saving
                                ? null
                                : (on) {
                                    setState(() {
                                      if (on) {
                                        _symptoms.add(label);
                                      } else {
                                        _symptoms.remove(label);
                                      }
                                    });
                                  },
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: _affectedController,
                      decoration: InputDecoration(
                        labelText: 'Birds affected (optional)',
                        helperText: liveBirds == null
                            ? null
                            : 'This batch has ${formatCount(liveBirds)} live birds.',
                      ),
                      keyboardType: TextInputType.number,
                      enabled: !_saving,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes (optional)',
                      ),
                      maxLines: 2,
                      textCapitalization: TextCapitalization.sentences,
                      enabled: !_saving,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Photos (optional · max $_maxPhotos)',
                      style: context.text.labelLarge,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SizedBox(
                      height: 92,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          for (final path in _localPhotoPaths)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(
                                      File(path),
                                      width: 92,
                                      height: 92,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: Material(
                                      color: context.scheme.scrim.withValues(
                                        alpha: 0.6,
                                      ),
                                      shape: const CircleBorder(),
                                      clipBehavior: Clip.antiAlias,
                                      child: InkWell(
                                        onTap: _saving
                                            ? null
                                            : () => setState(
                                                () => _localPhotoPaths.remove(
                                                  path,
                                                ),
                                              ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(4),
                                          child: Icon(
                                            Icons.close,
                                            size: 18,
                                            color: context.scheme.surface,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (_localPhotoPaths.length < _maxPhotos) ...[
                            _PhotoAddButton(
                              icon: Icons.photo_library_outlined,
                              label: 'Gallery',
                              onTap: _saving
                                  ? null
                                  : () => _pickPhoto(ImageSource.gallery),
                            ),
                            const SizedBox(width: 8),
                            _PhotoAddButton(
                              icon: Icons.photo_camera_outlined,
                              label: 'Camera',
                              onTap: _saving
                                  ? null
                                  : () => _pickPhoto(ImageSource.camera),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Card(
                      margin: EdgeInsets.zero,
                      child: Column(
                        children: [
                          SwitchListTile(
                            title: const Text('Request a vet'),
                            subtitle: Text(
                              hasGps
                                  ? 'Include your farm location'
                                  : 'Add farm GPS in profile for visits',
                              style: context.text.bodySmall,
                            ),
                            value: _requestVet,
                            onChanged: _saving
                                ? null
                                : (v) => setState(() => _requestVet = v),
                          ),
                          if (_requestVet && !hasGps)
                            ListTile(
                              dense: true,
                              leading: const Icon(Icons.location_on_outlined),
                              title: const Text('Add farm location'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: _saving
                                  ? null
                                  : () {
                                      context.pop();
                                      const MoreFarmRoute().push(context);
                                    },
                            ),
                          if (_requestVet) ...[
                            const Divider(height: 1),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                AppSpacing.md,
                                AppSpacing.sm,
                                AppSpacing.md,
                                0,
                              ),
                              child: Column(
                                children: [
                                  if (online)
                                    vetsAsync.when(
                                      loading: () => const SkeletonScope(
                                        child: SkeletonLine(height: 8),
                                      ),
                                      error: (_, __) => Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          const InlineBanner(
                                            message:
                                                'Could not load vets. You can still request any available vet.',
                                            icon: Icons.person_search_outlined,
                                            tone: BannerTone.warning,
                                          ),
                                          TextButton(
                                            onPressed: () => ref.invalidate(
                                              availableVetsProvider(
                                                widget.farmId,
                                              ),
                                            ),
                                            child: const Text('Try again'),
                                          ),
                                        ],
                                      ),
                                      data: (browse) {
                                        if (browse.vets.isEmpty) {
                                          return const SizedBox.shrink();
                                        }
                                        return DropdownButtonFormField<String?>(
                                          value: _requestedVetUserId,
                                          decoration: const InputDecoration(
                                            labelText: 'Veterinarian',
                                          ),
                                          items: [
                                            const DropdownMenuItem<String?>(
                                              value: null,
                                              child: Text('Any available vet'),
                                            ),
                                            for (final vet in browse.vets)
                                              DropdownMenuItem<String?>(
                                                value: vet.userId,
                                                child: Text(vet.displayName),
                                              ),
                                          ],
                                          onChanged: _saving
                                              ? null
                                              : (v) => setState(
                                                  () => _requestedVetUserId = v,
                                                ),
                                        );
                                      },
                                    ),
                                  const SizedBox(height: AppSpacing.sm),
                                  DropdownButtonFormField<String>(
                                    value: _serviceType,
                                    decoration: const InputDecoration(
                                      labelText: 'Service',
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'consultation',
                                        child: Text('Consultation'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'farm_visit',
                                        child: Text('Farm visit'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'either',
                                        child: Text('Either'),
                                      ),
                                    ],
                                    onChanged: _saving
                                        ? null
                                        : (v) => setState(
                                            () => _serviceType = v ?? 'either',
                                          ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _saving ? null : () => context.pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: _saving ? null : _submit,
                      child: _saving
                          ? AppBusyIndicator(
                              size: 22,
                              color: Theme.of(context).colorScheme.onPrimary,
                            )
                          : const Text('Save'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoAddButton extends StatelessWidget {
  const _PhotoAddButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 92,
          height: 92,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: context.scheme.primary),
              const SizedBox(height: 4),
              Text(label, style: context.text.labelSmall),
            ],
          ),
        ),
      ),
    );
  }
}
