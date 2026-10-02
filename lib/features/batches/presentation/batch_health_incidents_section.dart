import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/di/providers.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../../data_platform/db/app_database.dart';
import '../../health/data/health_repository.dart';

final batchHealthIncidentsProvider =
    StreamProvider.family<List<HealthRecordRow>, String>((ref, batchId) {
  return ref.watch(healthRepositoryProvider).watchForBatch(batchId);
});

class BatchHealthIncidentsSection extends ConsumerWidget {
  const BatchHealthIncidentsSection({required this.batchId, super.key});

  final String batchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incidentsAsync = ref.watch(batchHealthIncidentsProvider(batchId));

    return incidentsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (rows) {
        if (rows.isEmpty) {
          return const SizedBox.shrink();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.lg),
            _SectionHeading(title: 'Health incidents', count: rows.length),
            const SizedBox(height: AppSpacing.sm),
            ...rows.map((r) => _IncidentTile(record: r)),
          ],
        );
      },
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: context.text.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          '$count',
          style: context.text.labelLarge?.copyWith(
            color: context.scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _IncidentTile extends StatelessWidget {
  const _IncidentTile({required this.record});

  final HealthRecordRow record;

  @override
  Widget build(BuildContext context) {
    final date = DateFormat.yMMMd().format(record.occurredOn.toLocal());
    final symptoms = (jsonDecode(record.symptomsJson) as List)
        .map((e) => e.toString())
        .where((s) => s.isNotEmpty)
        .toList();
    final pendingPhotos = (jsonDecode(record.pendingPhotoPathsJson) as List)
        .where((p) => p.toString().isNotEmpty)
        .length;
    final uploadedPhotos = (jsonDecode(record.photoObjectKeysJson) as List)
        .where((p) => p.toString().isNotEmpty)
        .length;
    final photoCount = pendingPhotos + uploadedPhotos;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              record.summary,
              style: context.text.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              date,
              style: context.text.bodySmall?.copyWith(
                color: context.scheme.onSurfaceVariant,
              ),
            ),
            if (record.affectedBirdCount != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text('Birds affected: ${record.affectedBirdCount}'),
            ],
            if (symptoms.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final s in symptoms)
                    Chip(
                      label: Text(s),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
            ],
            if (photoCount > 0) ...[
              const SizedBox(height: AppSpacing.sm),
              _LocalPhotoStrip(record: record),
            ],
          ],
        ),
      ),
    );
  }
}

class _LocalPhotoStrip extends StatelessWidget {
  const _LocalPhotoStrip({required this.record});

  final HealthRecordRow record;

  @override
  Widget build(BuildContext context) {
    final pending = (jsonDecode(record.pendingPhotoPathsJson) as List)
        .map((e) => e.toString())
        .where((p) => p.isNotEmpty)
        .toList();

    if (pending.isEmpty) {
      return Text(
        '${(jsonDecode(record.photoObjectKeysJson) as List).length} photo(s) uploaded',
        style: context.text.labelMedium,
      );
    }

    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: pending.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final path = pending[index];
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(path),
              width: 72,
              height: 72,
              fit: BoxFit.cover,
            ),
          );
        },
      ),
    );
  }
}
