import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/layout/app_page.dart';
import '../../../app/layout/page_layout.dart';
import '../../auth/presentation/confirm_sign_out.dart';
import '../../auth/presentation/sign_out.dart';
import '../../../app/router/routes/typed_routes.dart';
import '../../settings/presentation/appearance_section.dart';
import '../../vet/presentation/find_vet_screen.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    if (!await confirmSignOut(context)) {
      return;
    }
    await signOutFromApp(ref);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return AppPage(
      primary: false,
      preset: PageLayout.form,
      frame: false,
      body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Farm & account',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.agriculture_outlined),
                title: const Text('Farm profile'),
                subtitle: const Text('Name, location, phone numbers'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => const MoreFarmRoute().push(context),
              ),
              const Divider(height: 1, indent: 56),
              ListTile(
                leading: const Icon(Icons.workspace_premium_outlined),
                title: const Text('Subscription'),
                subtitle: const Text('Coming soon'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Veterinary',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const Icon(Icons.person_search_outlined),
            title: const Text('Find a vet'),
            subtitle: const Text(
                'Locate a veterinary officer near your farm and contact them'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute<void>(
                builder: (_) => const FindVetScreen(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Preferences',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.notifications_outlined),
                title: const Text('Notifications'),
                subtitle: const Text('Due and overdue reminders'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => const NotificationsSettingsRoute().push(context),
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
            onTap: () => _signOut(context, ref),
          ),
        ),
      ],
      ),
    );
  }
}
