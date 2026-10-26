import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';
import '../../../app/layout/app_page.dart';
import '../../../app/router/routes/typed_routes.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../../app/widgets/states/app_snack.dart';
import '../../../app/widgets/states/async_state_view.dart';
import '../../../app/widgets/states/empty_state.dart';
import '../../../app/widgets/states/error_state.dart';
import '../../../app/widgets/states/offline_notice.dart';
import '../../../app/widgets/states/screen_skeletons.dart';
import '../../../core/error/failure.dart';
import '../../../core/error/failure_mapper.dart';
import '../domain/available_vet.dart';
import '../domain/vet_contact_launcher.dart';
import 'vet_inbox_providers.dart';

class FindVetScreen extends ConsumerWidget {
  const FindVetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider).value;
    final farmAsync = ref.watch(primaryFarmProvider);

    return AppPage(
      title: 'Find a Vet',
      scroll: false,
      frame: false,
      body: farmAsync.isLoading && !farmAsync.hasValue
          ? const ListSkeleton()
          : profile?.isDemo == true
              ? const EmptyState(
                  icon: Icons.lock_outline,
                  title: 'Sign in to find vets',
                  message:
                      'Demo mode has no cloud session. Sign in with a farmer '
                      'account to see veterinary officers near your farm.',
                )
              : _FindVetBody(farmId: farmAsync.value?.id),
    );
  }
}

class _FindVetBody extends ConsumerWidget {
  const _FindVetBody({required this.farmId});

  final String? farmId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final browse = ref.watch(availableVetsProvider(farmId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Header(browse: browse.asData?.value),
        Expanded(
          child: AsyncStateView(
            value: browse,
            skeleton: const ListSkeleton(),
            onRetry: () => ref.invalidate(availableVetsProvider(farmId)),
            error: (error, _) {
              if (error is SyncSignedOutDemo) {
                return const EmptyState(
                  icon: Icons.lock_outline,
                  title: 'Sign in to find vets',
                  message:
                      'Sign in with a farmer account to see veterinary '
                      'officers near your farm.',
                );
              }
              return ErrorState(
                failure: FailureMapper.mapObject(error),
                onRetry: () =>
                    ref.invalidate(availableVetsProvider(farmId)),
              );
            },
            builder: (data) {
              if (data.vets.isEmpty) {
                return RefreshIndicator(
                  onRefresh: () =>
                      ref.refresh(availableVetsProvider(farmId).future),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 48),
                      EmptyState(
                        icon: Icons.person_search_outlined,
                        title: 'No vets found nearby',
                        message:
                            'Veterinary officers appear here once they are '
                            'verified and share a contact number.',
                      ),
                    ],
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: () =>
                    ref.refresh(availableVetsProvider(farmId).future),
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.sm,
                    AppSpacing.md,
                    AppSpacing.xl,
                  ),
                  itemCount: data.vets.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.xs),
                  itemBuilder: (ctx, i) => _VetCard(vet: data.vets[i]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({this.browse});

  final AvailableVetsBrowse? browse;

  @override
  Widget build(BuildContext context) {
    final needsLocation = browse != null && !browse!.farmHasLocation;
    final message = browse?.farmNeedsSync == true
        ? 'Sync your farm to see distances.'
        : needsLocation
            ? 'Add your farm location to see distances.'
            : 'Contact a vet with WhatsApp, SMS, or a call.';

    return Material(
      color: context.scheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  color: context.scheme.primary,
                  size: 18,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    message,
                    style: context.text.bodySmall?.copyWith(
                      color: context.scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            if (needsLocation) ...[
              const SizedBox(height: AppSpacing.sm),
              FilledButton.tonal(
                onPressed: () => const MoreFarmRoute().push(context),
                child: const Text('Add farm location'),
              ),
            ],
            if (browse?.fromCache == true) ...[
              const SizedBox(height: AppSpacing.sm),
              StaleDataCaption(updatedLabel: _relative(browse!.fetchedAt)),
            ],
          ],
        ),
      ),
    );
  }
}

class _VetCard extends StatelessWidget {
  const _VetCard({required this.vet});

  final AvailableVet vet;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final phone = VetContactLauncher.normalizeUgandaPhone(vet.phone);

    return Card(
      elevation: AppSpacing.elevationCard,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                        style: context.text.bodySmall
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                if (vet.distanceKm != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                      vertical: AppSpacing.xxs,
                    ),
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
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.xs,
              children: [
                if (vet.offersConsultation)
                  const _ServiceChip(
                    icon: Icons.medical_services_outlined,
                    label: 'Consultation',
                  ),
                if (vet.offersFarmVisit)
                  const _ServiceChip(
                    icon: Icons.agriculture_outlined,
                    label: 'Farm visit',
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (phone != null)
              _ContactButtons(vet: vet, phone: phone)
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
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2 &&
        parts.first.isNotEmpty &&
        parts.last.isNotEmpty) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}

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
        _ContactButton(
          icon: Icons.chat_outlined,
          label: 'WhatsApp',
          semanticsLabel: 'Message ${vet.displayName} on WhatsApp',
          color: context.colors.whatsappGreen,
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
        _ContactButton(
          icon: Icons.sms_outlined,
          label: 'SMS',
          semanticsLabel: 'Send ${vet.displayName} an SMS',
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
        _ContactButton(
          icon: Icons.call_outlined,
          label: 'Call',
          semanticsLabel: 'Call ${vet.displayName}',
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
    required this.semanticsLabel,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String semanticsLabel;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticsLabel,
      child: OutlinedButton.icon(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color.withValues(alpha: 0.6)),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          minimumSize: const Size(48, 48),
          tapTargetSize: MaterialTapTargetSize.padded,
        ),
        icon: Icon(icon, size: 18),
        label: Text(label, style: context.text.labelMedium),
      ),
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
            color: context.scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

String _relative(DateTime at) {
  final delta = DateTime.now().difference(at);
  if (delta.inMinutes < 1) {
    return 'just now';
  }
  if (delta.inHours < 1) {
    return '${delta.inMinutes} min ago';
  }
  if (delta.inHours < 24) {
    return '${delta.inHours} h ago';
  }
  return '${delta.inDays} d ago';
}
