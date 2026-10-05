import 'package:flutter/material.dart';

import '../../../core/error/ui_failure.dart';
import '../../layout/content_frame.dart';
import '../../theme/app_spacing.dart';
import '../../theme/theme_context.dart';

class PermissionStateView extends StatelessWidget {
  const PermissionStateView({
    required this.permission,
    required this.blocked,
    required this.onAllow,
    super.key,
  });

  final AppPermission permission;
  final bool blocked;
  final VoidCallback onAllow;

  @override
  Widget build(BuildContext context) {
    final copy = _copy(permission);
    return ContentFrame(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(copy.icon, size: 40, color: context.colors.pendingSyncIndicator),
            const SizedBox(height: AppSpacing.md),
            Text(
              copy.title,
              style: context.text.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              copy.why,
              style: context.text.bodyMedium?.copyWith(
                color: context.scheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              copy.without,
              style: context.text.bodySmall?.copyWith(
                color: context.scheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: onAllow,
              child: Text(blocked ? 'Open settings' : 'Allow'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PermCopy {
  const _PermCopy(this.icon, this.title, this.why, this.without);
  final IconData icon;
  final String title;
  final String why;
  final String without;
}

_PermCopy _copy(AppPermission permission) {
  return switch (permission) {
    AppPermission.location => const _PermCopy(
        Icons.location_on_outlined,
        'Location helps the vet find your farm',
        'We save coordinates on your farm profile. We do not track you.',
        'You can still type a village or landmark instead.',
      ),
    AppPermission.camera => const _PermCopy(
        Icons.photo_camera_outlined,
        'Camera is used for health photos',
        'A photo helps a vet see what you noticed.',
        'You can send a report without a photo.',
      ),
    AppPermission.photos => const _PermCopy(
        Icons.photo_library_outlined,
        'Photos stay on this phone until you send them',
        'Pick a picture from your gallery to attach to a report.',
        'You can describe the problem in words instead.',
      ),
    AppPermission.notifications => const _PermCopy(
        Icons.notifications_outlined,
        'Reminders need notification access',
        'We alert you when a vaccination is due or overdue.',
        'Today still lists what is due, even if alerts are off.',
      ),
  };
}
