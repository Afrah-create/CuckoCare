import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../../app/widgets/states/app_snack.dart';
import '../../../app/widgets/states/progress_button.dart';
import '../../../core/logging/app_logger.dart';
import '../domain/feed_models.dart';

/// Bottom sheet for creating or editing a feed item.
class FeedItemFormSheet extends ConsumerStatefulWidget {
  const FeedItemFormSheet({this.existing, super.key});

  /// Null when creating a new item.
  final FeedItem? existing;

  static Future<void> show(
    BuildContext context,
    WidgetRef ref, {
    FeedItem? existing,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => FeedItemFormSheet(existing: existing),
    );
  }

  @override
  ConsumerState<FeedItemFormSheet> createState() => _FeedItemFormSheetState();
}

class _FeedItemFormSheetState extends ConsumerState<FeedItemFormSheet> {
  final _nameCtrl = TextEditingController();
  final _reorderCtrl = TextEditingController();
  var _feedType = FeedTypes.starter;
  var _unit = FeedUnits.kg;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _nameCtrl.text = e.name;
      _feedType = e.feedType;
      _unit = e.unit;
      if (e.reorderLevel != null) {
        _reorderCtrl.text = _formatDouble(e.reorderLevel!);
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _reorderCtrl.dispose();
    super.dispose();
  }

  bool get _isValid => _nameCtrl.text.trim().isNotEmpty;

  Future<bool> _save() async {
    final farmId = ref.read(primaryFarmProvider).value?.id;
    if (farmId == null) {
      AppSnack.error(context, 'No farm found. Please set up your farm first.');
      return false;
    }

    final input = FeedItemInput(
      name: _nameCtrl.text.trim(),
      feedType: _feedType,
      unit: _unit,
      reorderLevel: double.tryParse(_reorderCtrl.text.trim()),
    );

    try {
      final repo = ref.read(feedRepositoryProvider);
      if (_isEdit) {
        await repo.updateFeedItem(existing: widget.existing!, input: input);
      } else {
        await repo.addFeedItem(farmId: farmId, input: input);
      }
      return true;
    } catch (error, stack) {
      appLogger.e('Failed to save feed item', error: error, stackTrace: stack);
      if (mounted) {
        AppSnack.error(context, 'Could not save feed item. Please try again.');
      }
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 32,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: context.scheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text(
                _isEdit ? 'Edit Feed Item' : 'Add Feed Item',
                style: context.text.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Name
                    TextField(
                      controller: _nameCtrl,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Name *',
                        hintText: 'e.g. Chick Starter, Layer Mash',
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // Feed type
                    _LabeledField(
                      label: 'Feed type',
                      child: DropdownButtonFormField<String>(
                        initialValue: _feedType,
                        decoration: const InputDecoration(),
                        items: FeedTypes.all
                            .map(
                              (t) => DropdownMenuItem(
                                value: t,
                                child: Text(FeedTypes.label(t)),
                              ),
                            )
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _feedType = v ?? _feedType),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // Unit
                    _LabeledField(
                      label: 'Unit of measure',
                      child: DropdownButtonFormField<String>(
                        initialValue: _unit,
                        decoration: const InputDecoration(),
                        items: FeedUnits.all
                            .map(
                              (u) => DropdownMenuItem(
                                value: u,
                                child: Text(u),
                              ),
                            )
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _unit = v ?? _unit),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // Reorder level
                    TextField(
                      controller: _reorderCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d*'),
                        ),
                      ],
                      decoration: InputDecoration(
                        labelText: 'Reorder level (optional)',
                        hintText: 'Alert when stock falls below this',
                        suffixText: _unit,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ),
            // Action button
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.xs,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: ProgressButton(
                label: _isEdit ? 'Save changes' : 'Add feed item',
                busyLabel: 'Saving…',
                onPressed: _isValid ? _save : null,
                onSuccess: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDouble(double v) {
    return v.truncateToDouble() == v
        ? v.toInt().toString()
        : v.toString();
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: context.text.labelMedium),
        const SizedBox(height: AppSpacing.xxs),
        child,
      ],
    );
  }
}
