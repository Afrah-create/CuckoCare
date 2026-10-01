import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import 'login_state.dart';

class AuthModeSwitch extends StatelessWidget {
  const AuthModeSwitch({
    required this.mode,
    required this.onChanged,
    this.enabled = true,
    super.key,
  });

  final AuthFormMode mode;
  final ValueChanged<AuthFormMode> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    const height = 44.0;

    return Semantics(
      container: true,
      label: 'Authentication mode',
      child: SizedBox(
        height: 48,
        child: Center(
          child: Container(
            height: height,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(height / 2),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final half = constraints.maxWidth / 2;
                return Stack(
                  children: [
                    AnimatedAlign(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutCubic,
                      alignment: mode == AuthFormMode.signIn
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      child: Container(
                        width: half,
                        height: height - 6,
                        decoration: BoxDecoration(
                          color: scheme.surface,
                          borderRadius: BorderRadius.circular((height - 6) / 2),
                          border: Border.all(color: scheme.outlineVariant),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _Segment(
                            label: 'Sign in',
                            selected: mode == AuthFormMode.signIn,
                            onTap: enabled
                                ? () => onChanged(AuthFormMode.signIn)
                                : null,
                          ),
                        ),
                        Expanded(
                          child: _Segment(
                            label: 'Create account',
                            selected: mode == AuthFormMode.signUp,
                            onTap: enabled
                                ? () => onChanged(AuthFormMode.signUp)
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          child: Center(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: context.text.labelLarge!.copyWith(
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? scheme.onSurface : scheme.onSurfaceVariant,
              ),
              child: Text(label),
            ),
          ),
        ),
      ),
    );
  }
}
