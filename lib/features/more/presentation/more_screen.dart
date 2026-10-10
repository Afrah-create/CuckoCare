import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';
import '../../../app/layout/app_page.dart';
import '../../../app/layout/device_catalogue.dart';
import '../../../app/layout/layout_preview.dart';
import '../../../app/layout/page_layout.dart';
import '../../auth/presentation/confirm_sign_out.dart';
import '../../auth/presentation/sign_out.dart';
import '../../../app/router/routes/typed_routes.dart';
import '../../settings/presentation/appearance_section.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  Future<void> _pickWindowSize(BuildContext context, WidgetRef ref) async {
    final selected = await showModalBottomSheet<LayoutPreview?>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return ListView(
          children: [
            ListTile(
              title: const Text('This device'),
              onTap: () => Navigator.pop(sheetContext, const LayoutPreview(size: Size.zero)),
            ),
            for (final device in deviceProfiles)
              ListTile(
                title: Text(device.name),
                subtitle: Text(
                  '${device.size.width.toStringAsFixed(0)} × ${device.size.height.toStringAsFixed(0)}',
                ),
                onTap: () => Navigator.pop(
                  sheetContext,
                  LayoutPreview(size: device.size),
                ),
              ),
          ],
        );
      },
    );
    if (!context.mounted || selected == null) {
      return;
    }
    ref.read(layoutPreviewProvider.notifier).setPreview(
          selected.size == Size.zero ? null : selected,
        );
  }

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
                leading: const Icon(Icons.sync_problem_outlined),
                title: const Text('Sync diagnostics'),
                subtitle: const Text('Cursors, queue, failed ops'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => const MoreSyncRoute().push(context),
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
        if (ref.watch(envProvider).isDev) ...[
          const SizedBox(height: 24),
          Text(
            'Developer',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Layout inspector'),
                  subtitle: const Text('Profile, classes, and column count'),
                  value: ref.watch(layoutInspectorProvider),
                  onChanged: (value) => ref
                      .read(layoutInspectorProvider.notifier)
                      .setEnabled(value),
                ),
                ListTile(
                  leading: const Icon(Icons.devices_outlined),
                  title: const Text('Window size'),
                  subtitle: Text(
                    ref.watch(layoutPreviewProvider) == null
                        ? 'Using this device'
                        : 'Previewing a catalogue size',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _pickWindowSize(context, ref),
                ),
              ],
            ),
          ),
        ],
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
