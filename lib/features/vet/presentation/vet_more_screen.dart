import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';
import '../../../app/layout/app_page.dart';
import '../../../app/layout/page_layout.dart';
import '../../../app/theme/app_spacing.dart';
import '../../auth/presentation/confirm_sign_out.dart';
import '../../auth/presentation/sign_out.dart';
import '../../../app/router/routes/typed_routes.dart';
import '../../settings/presentation/appearance_section.dart';
import 'vet_gps_capture_card.dart';

class VetMoreScreen extends ConsumerWidget {
  const VetMoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profile = ref.watch(userProfileProvider).value;

    return AppPage(
      primary: false,
      preset: PageLayout.form,
      frame: false,
      body: ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        if (profile != null) ...[
          ListTile(
            leading: CircleAvatar(
              child: Text(profile.initials),
            ),
            title: Text(profile.displayName),
            subtitle: Text(profile.email ?? 'Veterinary account'),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        Card(
          child: ListTile(
            leading: const Icon(Icons.badge_outlined),
            title: const Text('Your profile'),
            subtitle: const Text('Name, phone, services, visibility'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => const VetProfileRoute().push(context),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        const VetGpsCaptureCard(),
        const SizedBox(height: AppSpacing.lg),
        const AppearanceSection(),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Session',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Card(
          child: ListTile(
            leading: Icon(Icons.logout, color: theme.colorScheme.error),
            title: Text(
              'Sign out',
              style: theme.textTheme.bodyLarge
                  ?.copyWith(color: theme.colorScheme.error),
            ),
            onTap: () async {
              if (!await confirmSignOut(context)) {
                return;
              }
              await signOutFromApp(ref);
            },
          ),
        ),
      ],
      ),
    );
  }
}
