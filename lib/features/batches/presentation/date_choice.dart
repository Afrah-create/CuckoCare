import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../domain/calendar_date.dart';
import 'batch_labels.dart';

/// Today / Yesterday chips with a date picker for anything older.
class DateChoice extends StatelessWidget {
  const DateChoice({
    required this.value,
    required this.today,
    required this.firstDate,
    required this.onChanged,
    super.key,
  });

  final CalendarDate value;
  final CalendarDate today;
  final CalendarDate firstDate;
  final ValueChanged<CalendarDate> onChanged;

  @override
  Widget build(BuildContext context) {
    final yesterday = today.addDays(-1);
    final allowYesterday = yesterday.compareTo(firstDate) >= 0;
    final isOther = value != today && value != yesterday;

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        ChoiceChip(
          label: const Text('Today'),
          selected: value == today,
          onSelected: (_) => onChanged(today),
        ),
        if (allowYesterday)
          ChoiceChip(
            label: const Text('Yesterday'),
            selected: value == yesterday,
            onSelected: (_) => onChanged(yesterday),
          ),
        ChoiceChip(
          avatar: const Icon(Icons.calendar_today_outlined, size: 18),
          label: Text(isOther ? formatDay(value) : 'Pick a date'),
          selected: isOther,
          onSelected: (_) => _pick(context),
        ),
      ],
    );
  }

  Future<void> _pick(BuildContext context) async {
    final first = firstDate.compareTo(today) > 0 ? today : firstDate;
    final initial = value.compareTo(first) < 0 ? first : value;
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(initial.year, initial.month, initial.day),
      firstDate: DateTime(first.year, first.month, first.day),
      lastDate: DateTime(today.year, today.month, today.day),
    );
    if (picked != null) {
      onChanged(CalendarDate.fromDateTime(picked));
    }
  }
}
