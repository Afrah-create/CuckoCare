import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/theme_context.dart';

class FilterChipOption<T> {
  const FilterChipOption({required this.value, required this.label});

  final T value;
  final String label;
}

/// One-line scrolling choice chips. Avoids Wrap overflow on phone widths.
class FilterChipStrip<T> extends StatelessWidget {
  const FilterChipStrip({
    required this.selected,
    required this.options,
    required this.onSelected,
    super.key,
  });

  final T selected;
  final List<FilterChipOption<T>> options;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: options.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.xs),
        itemBuilder: (context, index) {
          final option = options[index];
          final isSelected = option.value == selected;
          return FilterChip(
            label: Text(option.label),
            selected: isSelected,
            showCheckmark: false,
            visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            padding: EdgeInsets.zero,
            labelPadding: const EdgeInsets.symmetric(horizontal: 10),
            side: BorderSide(
              color: isSelected
                  ? context.scheme.primary
                  : context.scheme.outlineVariant,
            ),
            onSelected: (_) => onSelected(option.value),
          );
        },
      ),
    );
  }
}
