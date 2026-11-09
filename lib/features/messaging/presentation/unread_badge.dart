import 'package:flutter/material.dart';

import '../../../app/theme/theme_context.dart';
import '../../../app/widgets/states/animated_count.dart';
import '../domain/message_metrics.dart';

class UnreadBadge extends StatelessWidget {
  const UnreadBadge({required this.count, super.key});

  final int count;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();
    final label = MessageMetrics.badgeLabel(count);
    return Semantics(
      label: '$count unread messages',
      child: Badge(
        label: AnimatedCount(
          value: count > 99 ? 99 : count,
          style: context.text.labelSmall?.copyWith(
            color: context.scheme.onError,
            fontWeight: FontWeight.w700,
          ),
        ),
        child: Text(label, style: context.text.labelSmall),
      ),
    );
  }
}

class NavUnreadIcon extends StatelessWidget {
  const NavUnreadIcon({
    required this.icon,
    required this.count,
    super.key,
  });

  final IconData icon;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Badge(
      isLabelVisible: count > 0,
      label: count > 0 ? Text(MessageMetrics.badgeLabel(count)) : null,
      child: Icon(icon),
    );
  }
}

class UnreadDot extends StatelessWidget {
  const UnreadDot({required this.count, super.key});

  final int count;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();
    return Semantics(
      label: '$count unread messages',
      child: Badge(smallSize: 8, child: const SizedBox(width: 8, height: 8)),
    );
  }
}
