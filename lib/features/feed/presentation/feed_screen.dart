import 'package:flutter/material.dart';

import '../../../app/widgets/tab_empty_state.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TabEmptyState(
      icon: Icons.restaurant_outlined,
      title: 'Feed & stock',
      message: 'Feed items and transactions will appear here.',
    );
  }
}
