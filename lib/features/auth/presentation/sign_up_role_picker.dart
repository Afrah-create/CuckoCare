import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../domain/app_role.dart';

class SignUpRolePicker extends StatelessWidget {
  const SignUpRolePicker({
    required this.selected,
    required this.onSelected,
    this.enabled = true,
    super.key,
  });

  final AppRole selected;
  final ValueChanged<AppRole> onSelected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'What best describes you?',
          style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.sm),
        _RoleTile(
          role: AppRole.farmer,
          title: 'Farmer',
          subtitle: 'Manage flocks, schedules, and farm records offline.',
          icon: Icons.agriculture_outlined,
          selected: selected == AppRole.farmer,
          enabled: enabled,
          onTap: () => onSelected(AppRole.farmer),
        ),
        const SizedBox(height: AppSpacing.xs),
        _RoleTile(
          role: AppRole.vet,
          title: 'Veterinary professional',
          subtitle: 'Review assistance requests and respond to farmers.',
          icon: Icons.medical_services_outlined,
          selected: selected == AppRole.vet,
          enabled: enabled,
          onTap: () => onSelected(AppRole.vet),
        ),
      ],
    );
  }
}

class _RoleTile extends StatelessWidget {
  const _RoleTile({
    required this.role,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final AppRole role;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    return Material(
      color: selected ? scheme.primaryContainer : scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: selected ? scheme.onPrimaryContainer : scheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: context.text.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: selected
                            ? scheme.onPrimaryContainer
                            : scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: context.text.bodySmall?.copyWith(
                        color: selected
                            ? scheme.onPrimaryContainer
                            : scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                Icon(Icons.check_circle, color: scheme.onPrimaryContainer),
            ],
          ),
        ),
      ),
    );
  }
}
