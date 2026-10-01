import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';

/// Header card for the Today tab with a subtle welcome animation.
class TodayGreetingCard extends StatefulWidget {
  const TodayGreetingCard({
    required this.greeting,
    required this.subtitle,
    this.compact = false,
    super.key,
  });

  final String greeting;
  final String subtitle;
  final bool compact;

  @override
  State<TodayGreetingCard> createState() => _TodayGreetingCardState();
}

class _TodayGreetingCardState extends State<TodayGreetingCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _wave;
  bool _animConfigured = false;

  @override
  void initState() {
    super.initState();
    _wave = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_animConfigured) {
      return;
    }
    _animConfigured = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _wave.value = 1;
    } else {
      _wave.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _wave.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final colors = context.colors;
    final wave = Tween<double>(begin: -0.08, end: 0.14).animate(
      CurvedAnimation(parent: _wave, curve: Curves.easeInOut),
    );

    if (widget.compact) {
      return ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 120),
        child: Card(
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.waving_hand_rounded,
                  size: 24,
                  color: colors.logoTint,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    widget.greeting,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              scheme.primaryContainer.withValues(alpha: 0.55),
              scheme.surfaceContainerHighest.withValues(alpha: 0.85),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: AnimatedBuilder(
                    animation: wave,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: wave.value,
                        alignment: Alignment.bottomCenter,
                        child: child,
                      );
                    },
                    child: Icon(
                      Icons.waving_hand_rounded,
                      size: 28,
                      color: colors.logoTint,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.greeting,
                      style: context.text.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      widget.subtitle,
                      style: context.text.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
