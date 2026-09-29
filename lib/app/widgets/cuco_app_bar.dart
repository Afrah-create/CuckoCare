import 'package:flutter/material.dart';

import '../../data_platform/sync/sync_engine.dart';
import 'sync_status_badge.dart';

class CucoAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CucoAppBar({
    required this.title,
    required this.profileInitials,
    required this.onProfileTap,
    this.syncStatus,
    super.key,
  });

  final String title;
  final String profileInitials;
  final VoidCallback onProfileTap;
  final SyncStatus? syncStatus;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AppBar(
      title: Row(
        children: [
          Icon(Icons.egg_alt_outlined, color: scheme.primary, size: 26),
          const SizedBox(width: 10),
          Text(title),
        ],
      ),
      actions: [
        if (syncStatus != null) SyncStatusBadge(status: syncStatus!),
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: IconButton(
            tooltip: 'Account',
            onPressed: onProfileTap,
            icon: CircleAvatar(
              radius: 18,
              backgroundColor: scheme.primaryContainer,
              foregroundColor: scheme.onPrimaryContainer,
              child: Text(
                profileInitials,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
