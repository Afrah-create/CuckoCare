import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'layout_preview.dart';
import 'layout_scope.dart';

/// Shows the values [LayoutScope] is currently publishing.
class LayoutInspectorBanner extends ConsumerWidget {
  const LayoutInspectorBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layout = context.layout;
    final columns = layout.columnsFor(layout.size.width);
    final label =
        '${layout.size.width.toStringAsFixed(0)}×${layout.size.height.toStringAsFixed(0)} dp\n'
        '${layout.profile.name} · ${layout.widthClass.name} / ${layout.heightClass.name}\n'
        'text ${layout.textScale.toStringAsFixed(2)} · columns $columns\n'
        'short ${layout.isShort} · narrow ${layout.isNarrow} · '
        'large text ${layout.isLargeText}\n'
        'side inset ${layout.sideInset.toStringAsFixed(0)} · '
        'reduced motion ${layout.reducedMotion}';

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Material(
        elevation: 3,
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).colorScheme.inverseSurface,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 280),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onInverseSurface,
                        ),
                  ),
                ),
                IconButton(
                  tooltip: 'Hide layout inspector',
                  onPressed: () => ref
                      .read(layoutInspectorProvider.notifier)
                      .setEnabled(false),
                  icon: Icon(
                    Icons.close,
                    color: Theme.of(context).colorScheme.onInverseSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
