import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/di/providers.dart';
import '../../../app/router/routes/typed_routes.dart';
import '../../farms/domain/farm_profile.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../data/health_repository.dart';

Future<bool?> showReportHealthConcernSheet(
  BuildContext context, {
  required String batchId,
  required String farmId,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (ctx) => _ReportHealthConcernSheet(
      batchId: batchId,
      farmId: farmId,
    ),
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
  bool _requestVet = false;
  String _serviceType = 'either';
  bool _saving = false;

  @override
  void dispose() {
    _summaryController.dispose();
    _notesController.dispose();
    _affectedController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_saving) {
      return;
    }
    setState(() => _saving = true);
    try {
      final affected = int.tryParse(_affectedController.text.trim());
      await ref.read(healthRepositoryProvider).reportConcern(
            ReportHealthConcernInput(
              batchId: widget.batchId,
              farmId: widget.farmId,
              summary: _summaryController.text,
              notes: _notesController.text,
              affectedBirdCount: affected,
              requestVet: _requestVet,
              serviceType: _serviceType,
            ),
          );
      ref.read(syncSchedulerProvider).notifyLocalWrite();
      if (mounted) {
        context.pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _requestVet
                  ? 'Health concern saved. Vet request will send when online.'
                  : 'Health concern saved.',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    final farm = ref.watch(primaryFarmProvider).value;
    final hasGps = farmHasGps(farm);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md + bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Report health concern',
              style: context.text.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _summaryController,
              decoration: const InputDecoration(
                labelText: 'What did you notice?',
                hintText: 'e.g. coughing, reduced appetite',
              ),
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _affectedController,
              decoration: const InputDecoration(
                labelText: 'Birds affected (optional)',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Additional notes (optional)',
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: AppSpacing.md),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Request veterinarian assistance'),
              subtitle: Text(
                hasGps
                    ? 'Queued offline; sent when you are back online.'
                    : 'Add farm GPS in your profile to share location with the vet.',
              ),
              value: _requestVet,
              onChanged: _saving ? null : (v) => setState(() => _requestVet = v),
            ),
            if (_requestVet && !hasGps) ...[
              const SizedBox(height: AppSpacing.xs),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _saving
                      ? null
                      : () {
                          context.pop();
                          const MoreFarmRoute().push(context);
                        },
                  icon: const Icon(Icons.location_on_outlined),
                  label: const Text('Capture farm location'),
                ),
              ),
            ],
            if (_requestVet) ...[
              const SizedBox(height: AppSpacing.xs),
              DropdownButtonFormField<String>(
                value: _serviceType,
                decoration: const InputDecoration(
                  labelText: 'Service needed',
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'consultation',
                    child: Text('Phone / chat consultation'),
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
                    : (v) => setState(() => _serviceType = v ?? 'either'),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: _saving ? null : _submit,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
