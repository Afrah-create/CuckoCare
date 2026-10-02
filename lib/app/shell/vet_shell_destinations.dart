import 'package:flutter/material.dart';

abstract final class VetShellDestinations {
  static const tabs = [
    VetShellTab(
      outlined: Icons.inbox_outlined,
      filled: Icons.inbox_rounded,
      label: 'Requests',
      semanticsLabel: 'Assistance requests',
    ),
    VetShellTab(
      outlined: Icons.map_outlined,
      filled: Icons.map_rounded,
      label: 'Map',
      semanticsLabel: 'Request map',
    ),
    VetShellTab(
      outlined: Icons.assignment_outlined,
      filled: Icons.assignment_rounded,
      label: 'Active',
      semanticsLabel: 'Active cases',
    ),
    VetShellTab(
      outlined: Icons.more_horiz_outlined,
      filled: Icons.more_horiz_rounded,
      label: 'More',
      semanticsLabel: 'More',
    ),
  ];
}

class VetShellTab {
  const VetShellTab({
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
