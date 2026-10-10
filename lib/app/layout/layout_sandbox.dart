import 'package:flutter/material.dart';

import 'app_page.dart';
import 'page_layout.dart';

/// Proves a screen is responsive with only [AppPage] and a preset.
class LayoutSandbox extends StatelessWidget {
  const LayoutSandbox({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Layout sandbox',
      preset: PageLayout.standard,
      scroll: true,
      body: const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('A new screen uses AppPage and a preset.'),
          SizedBox(height: 16),
          FilledButton(onPressed: null, child: Text('Primary action')),
        ],
      ),
    );
  }
}
