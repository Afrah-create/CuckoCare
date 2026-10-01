import 'package:flutter/material.dart';

import 'theme_mode_selector.dart';

class AppearanceSection extends StatelessWidget {
  const AppearanceSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: ThemeModeSelector(),
      ),
    );
  }
}
