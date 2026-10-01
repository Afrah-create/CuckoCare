import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Edge-to-edge system bars styled from the active [ThemeData].
class ThemedSystemUi extends StatefulWidget {
  const ThemedSystemUi({required this.child, super.key});

  final Widget child;

  @override
  State<ThemedSystemUi> createState() => _ThemedSystemUiState();
}

class _ThemedSystemUiState extends State<ThemedSystemUi> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final overlay = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      systemNavigationBarIconBrightness:
          isDark ? Brightness.light : Brightness.dark,
      systemNavigationBarDividerColor: scheme.outlineVariant.withValues(
        alpha: 0.3,
      ),
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlay,
      child: widget.child,
    );
  }
}
