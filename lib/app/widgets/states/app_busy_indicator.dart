import 'package:flutter/material.dart';

import '../../theme/theme_context.dart';

class AppBusyIndicator extends StatelessWidget {
  const AppBusyIndicator({
    this.size = 22,
    this.strokeWidth = 2,
    this.value,
    this.color,
    super.key,
  });

  final double size;
  final double strokeWidth;
  final double? value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        value: value,
        color: color ?? context.scheme.primary,
      ),
    );
  }
}
