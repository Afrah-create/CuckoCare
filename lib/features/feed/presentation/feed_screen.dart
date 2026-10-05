import 'package:flutter/material.dart';

import '../../../app/widgets/states/empty_state.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      icon: Icons.restaurant_outlined,
      title: 'No feed items yet',
      message: 'Add feed to track stock. This works offline.',
    );
  }
}
