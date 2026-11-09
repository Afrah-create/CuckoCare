import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../../app/widgets/filter_chip_strip.dart';
import '../domain/farmer_incident_filters.dart';

class FarmerIncidentFilterBar extends StatelessWidget {
  const FarmerIncidentFilterBar({
    required this.value,
    required this.symptoms,
    required this.onChanged,
    super.key,
  });

  final FarmerIncidentFilters value;
  final List<String> symptoms;
  final ValueChanged<FarmerIncidentFilters> onChanged;

  static const _queues = [
    FilterChipOption(value: FarmerIncidentQueue.all, label: 'All'),
    FilterChipOption(
      value: FarmerIncidentQueue.awaiting,
      label: 'Awaiting vet',
    ),
    FilterChipOption(value: FarmerIncidentQueue.withVet, label: 'With vet'),
    FilterChipOption(value: FarmerIncidentQueue.closed, label: 'Closed'),
    FilterChipOption(value: FarmerIncidentQueue.draft, label: 'Not sent'),
  ];

  static const _sorts = [
    (FarmerIncidentSort.newest, 'Newest'),
    (FarmerIncidentSort.oldest, 'Oldest'),
    (FarmerIncidentSort.mostAffected, 'Most affected'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: FilterChipStrip<FarmerIncidentQueue>(
                selected: value.queue,
                options: _queues,
                onSelected: (queue) => onChanged(value.copyWith(queue: queue)),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            PopupMenuButton<FarmerIncidentSort>(
              tooltip: 'Sort incidents',
              initialValue: value.sort,
              onSelected: (sort) => onChanged(value.copyWith(sort: sort)),
              itemBuilder: (context) => [
                for (final sort in _sorts)
                  PopupMenuItem(value: sort.$1, child: Text(sort.$2)),
              ],
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.sort,
                      size: 18,
                      color: context.scheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _sorts.firstWhere((s) => s.$1 == value.sort).$2,
                      style: context.text.labelMedium,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (symptoms.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          FilterChipStrip<String?>(
            selected: value.symptom,
            options: [
              const FilterChipOption(value: null, label: 'All symptoms'),
              for (final symptom in symptoms)
                FilterChipOption(value: symptom, label: symptom),
            ],
            onSelected: (symptom) =>
                onChanged(value.copyWith(symptom: () => symptom)),
          ),
        ],
      ],
    );
  }
}
