import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/di/providers.dart';
import '../../../app/layout/content_frame.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../../data_platform/db/app_database.dart';
import 'farm_gps_capture_card.dart';
import 'farm_setup_controller.dart';

class FarmSetupScreen extends ConsumerStatefulWidget {
  const FarmSetupScreen({super.key});

  @override
  ConsumerState<FarmSetupScreen> createState() => _FarmSetupScreenState();
}

class _FarmSetupScreenState extends ConsumerState<FarmSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _districtController = TextEditingController();
  final _villageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _altPhoneController = TextEditingController();
  final _notesController = TextEditingController();
  var _userEdited = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _userEdited) {
        return;
      }
      final farm = ref.read(primaryFarmProvider).value;
      if (farm != null) {
        _fillFromFarm(farm);
      }
    });
  }

  void _fillFromFarm(FarmRow farm) {
    _nameController.text = farm.name;
    _districtController.text = farm.district ?? '';
    _villageController.text = farm.village ?? '';
    _phoneController.text = farm.phone ?? '';
    _altPhoneController.text = farm.altPhone ?? '';
    _notesController.text = farm.notes ?? '';
  }

  void _markEdited() {
    _userEdited = true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _districtController.dispose();
    _villageController.dispose();
    _phoneController.dispose();
    _altPhoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final ok = await ref.read(farmSetupControllerProvider.notifier).submit(
          name: _nameController.text,
          district: _districtController.text,
          village: _villageController.text,
          phone: _phoneController.text,
          altPhone: _altPhoneController.text,
          notes: _notesController.text,
        );
    if (ok && mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(primaryFarmProvider, (previous, next) {
      final farm = next.value;
      if (farm != null && !_userEdited && mounted) {
        _fillFromFarm(farm);
      }
    });

    final setup = ref.watch(farmSetupControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Farm profile'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: setup.isSubmitting ? null : () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: ContentFrame(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: ContentFrame.scrollBottomInset(context),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Complete your farm details',
                    style: context.text.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Required for sync and support. You can update this anytime.',
                    style: context.text.bodyMedium?.copyWith(
                      color: context.scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const FarmGpsCaptureCard(),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Contact & location',
                    style: context.text.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _nameController,
                  onChanged: (_) => _markEdited(),
                  enabled: !setup.isSubmitting,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'Farm name'),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _districtController,
                  enabled: !setup.isSubmitting,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'District'),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _villageController,
                  enabled: !setup.isSubmitting,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'Village / parish'),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _phoneController,
                  enabled: !setup.isSubmitting,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    prefixText: '+256 ',
                  ),
                  validator: (v) {
                    final digits = v?.replaceAll(RegExp(r'\D'), '') ?? '';
                    if (digits.length < 9) {
                      return 'Enter a valid phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _altPhoneController,
                  enabled: !setup.isSubmitting,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Alternate phone (optional)',
                    prefixText: '+256 ',
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _notesController,
                  enabled: !setup.isSubmitting,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                  ),
                ),
                if (setup.errorMessage != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    setup.errorMessage!,
                    style: context.text.bodyMedium?.copyWith(
                      color: context.scheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                FilledButton(
                  onPressed: setup.isSubmitting ? null : _submit,
                  child: setup.isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save farm profile'),
                ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
