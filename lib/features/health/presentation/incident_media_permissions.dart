import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/widgets/states/app_dialog.dart';

/// In-app consent before opening the camera or gallery.
/// OS permissions are requested by [ImagePicker] when picking.
Future<bool> confirmIncidentCamera(BuildContext context) async {
  final proceed = await showAppDialog<bool>(
    context: context,
    builder: (ctx) => AppDialog(
      icon: Icon(
        Icons.photo_camera_outlined,
        color: Theme.of(ctx).colorScheme.primary,
      ),
      title: const Text('Take a photo?'),
      content: const Text(
        'Your phone will ask to use the camera. You can add up to 3 photos.',
      ),
      actions: [
        TextButton(
          onPressed: () => ctx.pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => ctx.pop(true),
          child: const Text('Continue'),
        ),
      ],
    ),
  );
  return proceed ?? false;
}

Future<bool> confirmIncidentGallery(BuildContext context) async {
  final proceed = await showAppDialog<bool>(
    context: context,
    builder: (ctx) => AppDialog(
      icon: Icon(
        Icons.photo_library_outlined,
        color: Theme.of(ctx).colorScheme.primary,
      ),
      title: const Text('Choose from gallery?'),
      content: const Text(
        'Your phone may ask to access photos. You can add up to 3 images.',
      ),
      actions: [
        TextButton(
          onPressed: () => ctx.pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => ctx.pop(true),
          child: const Text('Continue'),
        ),
      ],
    ),
  );
  return proceed ?? false;
}
