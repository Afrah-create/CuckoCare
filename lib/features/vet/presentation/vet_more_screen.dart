import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';
import '../../../app/layout/app_page.dart';
import '../../../app/layout/page_layout.dart';
import '../../../app/router/routes/typed_routes.dart';
import '../../auth/presentation/confirm_sign_out.dart';
import '../../auth/presentation/sign_out.dart';
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
      padding: const EdgeInsets.all(16),
      children: [
        if (profile != null) ...[
          ListTile(
            leading: CircleAvatar(
              child: Text(profile.initials),
            ),
            title: Text(profile.displayName),
            subtitle: Text(profile.email ?? 'Veterinary account'),
          ),
          const SizedBox(height: 16),
        ],
        const VetGpsCaptureCard(),
        const SizedBox(height: 24),
        Text(
          'Practice tools',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.sync_problem_outlined),
                title: const Text('Sync diagnostics'),
                subtitle: const Text('Queue and connection status'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => const VetSyncRoute().push(context),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const AppearanceSection(),
        const SizedBox(height: 24),
        Text(
          'Session',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
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
