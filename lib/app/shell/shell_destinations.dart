import 'package:flutter/material.dart';

/// Bottom navigation and rail destinations (Material rounded / outlined pairs).
abstract final class ShellDestinations {
  static const tabs = [
    ShellTab(
      outlined: Icons.view_day_outlined,
      filled: Icons.view_day_rounded,
      label: 'Today',
      semanticsLabel: 'Today',
    ),
    ShellTab(
      outlined: Icons.widgets_outlined,
      filled: Icons.widgets_rounded,
      label: 'Batches',
      semanticsLabel: 'Batches',
    ),
    ShellTab(
      outlined: Icons.eco_outlined,
      filled: Icons.eco_rounded,
      label: 'Feed',
      semanticsLabel: 'Feed',
    ),
    ShellTab(
      outlined: Icons.fact_check_outlined,
      filled: Icons.fact_check_rounded,
      label: 'Records',
      semanticsLabel: 'Records',
    ),
    ShellTab(
      outlined: Icons.more_horiz_outlined,
      filled: Icons.more_horiz_rounded,
      label: 'More',
      semanticsLabel: 'More',
    ),
  ];
}

class ShellTab {
  const ShellTab({
    required this.outlined,
    required this.filled,
    required this.label,
    required this.semanticsLabel,
  });

  final IconData outlined;
  final IconData filled;
  final String label;
  final String semanticsLabel;
}
