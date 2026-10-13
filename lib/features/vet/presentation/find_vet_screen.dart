import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';
import '../../../app/layout/app_page.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../../app/widgets/states/app_snack.dart';
import '../../../app/widgets/states/async_state_view.dart';
import '../../../app/widgets/states/empty_state.dart';
import '../../../app/widgets/states/screen_skeletons.dart';
import '../data/vet_directory_repository.dart';
import '../domain/vet_contact_launcher.dart';
import 'vet_inbox_providers.dart';

/// Dev-only stub vet injected at the top of the list for testing WhatsApp/SMS.
/// Removed when [Env.isDev] is false.
final _stubVet = AvailableVet(
  userId: 'stub-test-vet-001',
  displayName: 'Dr. Test Vet (Dev)',
  organization: 'CucoCare Test Clinic',
  district: 'Kampala',
  phone: '+256730561129',
  offersConsultation: true,
  offersFarmVisit: true,
  distanceKm: 0.5,
);

/// Farmer-facing screen: find a vet near their farm and contact them via
/// WhatsApp, SMS (Airtel/MTN), or a phone call.
class FindVetScreen extends ConsumerWidget {
  const FindVetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final farmId = ref.watch(primaryFarmProvider).value?.id;
    final vetsAsync = ref.watch(availableVetsProvider(farmId));
    final env = ref.read(envProvider);

    return AppPage(
      title: 'Find a Vet',
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(),
          Expanded(
            child: AsyncStateView(
              value: vetsAsync,
              skeleton: const ListSkeleton(),
              onRetry: () => ref.invalidate(availableVetsProvider(farmId)),
              // On error in dev: still show the stub so testing is unblocked.
              error: env.isDev
                  ? (_, __) => _VetList(vets: [_stubVet])
                  : null,
              builder: (vets) {
                final displayVets = env.isDev
                    ? [_stubVet, ...vets]
                    : vets;
                if (displayVets.isEmpty) {
                  return const EmptyState(
                    icon: Icons.person_search_outlined,
                    title: 'No vets found nearby',
                    message:
                        'Veterinary officers near your farm will appear here '
                        'once they register and share their location.',
                  );
                }
                return _VetList(vets: displayVets);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _VetList extends StatelessWidget {
  const _VetList({required this.vets});
  final List<AvailableVet> vets;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.xl,
      ),
      itemCount: vets.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.xs),
      itemBuilder: (ctx, i) => _VetCard(vet: vets[i]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.scheme.surfaceContainerLow,
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.md),
      child: Row(
        children: [
          Icon(Icons.location_on_outlined,
              color: context.scheme.primary, size: 18),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              'Vets sorted by distance from your farm. '
              'Tap a card to contact them directly.',
              style: context.text.bodySmall?.copyWith(
                color: context.scheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _VetCard extends StatelessWidget {
  const _VetCard({required this.vet});
  final AvailableVet vet;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final hasPhone = vet.phone != null && vet.phone!.isNotEmpty;
    final normalizedPhone = hasPhone
        ? VetContactLauncher.normalizeUgandaPhone(vet.phone!)
        : null;

    return Card(
      elevation: AppSpacing.elevationCard,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name row + distance badge
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: scheme.primaryContainer,
                  child: Text(
                    _initials(vet.displayName),
                    style: context.text.titleSmall?.copyWith(
                      color: scheme.onPrimaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vet.displayName,
                        style: context.text.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        vet.subtitle,
                        style: context.text.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                if (vet.distanceKm != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs, vertical: AppSpacing.xxs),
                    decoration: BoxDecoration(
                      color: scheme.secondaryContainer,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Text(
                      '${vet.distanceKm!.toStringAsFixed(1)} km',
                      style: context.text.labelSmall?.copyWith(
                        color: scheme.onSecondaryContainer,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            // Services
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.xs,
              children: [
                if (vet.offersConsultation)
                  _ServiceChip(
                      icon: Icons.medical_services_outlined,
                      label: 'Consultation'),
                if (vet.offersFarmVisit)
                  _ServiceChip(
                      icon: Icons.agriculture_outlined,
                      label: 'Farm visit'),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            // Contact buttons
            if (hasPhone && normalizedPhone != null)
              _ContactButtons(vet: vet, phone: normalizedPhone)
            else
              Text(
                'No contact number available yet.',
                style: context.text.bodySmall
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
          ],
        ),
      ),
    );
  }

  static String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ContactButtons extends StatelessWidget {
  const _ContactButtons({required this.vet, required this.phone});
  final AvailableVet vet;
  final String phone;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        // WhatsApp
        _ContactButton(
          icon: Icons.chat_outlined,
          label: 'WhatsApp',
          color: const Color(0xFF25D366),
          onTap: () => _launch(
            context,
            () => VetContactLauncher.whatsApp(
              phone,
              message:
                  'Hello ${vet.displayName}, I am a farmer using CucoCare '
                  'and need veterinary advice for my flock.',
            ),
            fallback: 'WhatsApp is not installed.',
          ),
        ),
        // SMS
        _ContactButton(
          icon: Icons.sms_outlined,
          label: 'SMS',
          color: context.scheme.primary,
          onTap: () => _launch(
            context,
            () => VetContactLauncher.sms(
              phone,
              body:
                  'Hello ${vet.displayName}, I am a farmer using CucoCare '
                  'and need veterinary advice.',
            ),
            fallback: 'Could not open SMS app.',
          ),
        ),
        // Call
        _ContactButton(
          icon: Icons.call_outlined,
          label: 'Call',
          color: context.scheme.tertiary,
          onTap: () => _launch(
            context,
            () => VetContactLauncher.call(phone),
            fallback: 'Could not open the dialer.',
          ),
        ),
      ],
    );
  }

  Future<void> _launch(
    BuildContext context,
    Future<bool> Function() action, {
    required String fallback,
  }) async {
    final ok = await action();
    if (!ok && context.mounted) {
      AppSnack.error(context, fallback);
    }
  }
}

class _ContactButton extends StatelessWidget {
  const _ContactButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withValues(alpha: 0.6)),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
        minimumSize: const Size(0, 36),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 13)),
    );
  }
}

class _ServiceChip extends StatelessWidget {
  const _ServiceChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: context.scheme.onSurfaceVariant),
        const SizedBox(width: 3),
        Text(
          label,
          style: context.text.labelSmall?.copyWith(
              color: context.scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
