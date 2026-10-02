import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

/// In-app consent before the OS location permission sheet.
Future<bool> confirmFarmGpsPermission(BuildContext context) async {
  final permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.always ||
      permission == LocationPermission.whileInUse) {
    return true;
  }

  if (!context.mounted) {
    return false;
  }

  final proceed = await showDialog<bool>(
    context: context,
    builder: (ctx) {
      final scheme = Theme.of(ctx).colorScheme;
      return AlertDialog(
        icon: Icon(Icons.location_on_outlined, color: scheme.primary, size: 32),
        title: const Text('Use your location?'),
        content: const Text(
          'CucoCare will read your GPS once while you are at the farm. '
          'This helps veterinarians find you when you request assistance. '
          'You can update or skip this anytime.',
        ),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(false),
            child: const Text('Not now'),
          ),
          FilledButton(
            onPressed: () => ctx.pop(true),
            child: const Text('Continue'),
          ),
        ],
      );
    },
  );

  return proceed ?? false;
}

/// Shown when the user should enable GPS in system settings.
Future<void> showFarmGpsSettingsHint(
  BuildContext context, {
  required bool locationServices,
}) async {
  await showDialog<void>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: Text(
          locationServices ? 'Allow location for CucoCare' : 'Turn on GPS',
        ),
        content: Text(
          locationServices
              ? 'Location was blocked. Open Settings, allow location for CucoCare, then try capture again.'
              : 'Enable location services on this device, then return here to capture your farm.',
        ),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(),
            child: const Text('Close'),
          ),
        ],
      );
    },
  );
}
