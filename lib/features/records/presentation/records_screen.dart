import 'package:flutter/material.dart';

import '../../../app/widgets/tab_empty_state.dart';

class RecordsScreen extends StatelessWidget {
  const RecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TabEmptyState(
      icon: Icons.note_alt_outlined,
      title: 'Records',
      message: 'Health, mortality, and farm events will be grouped here.',
    );
  }
}
