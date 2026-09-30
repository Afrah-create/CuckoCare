import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import '../../splash/splash_mark.dart';

/// Dev-only scrubber for splash choreography.
class SplashPreviewScreen extends StatefulWidget {
  const SplashPreviewScreen({super.key});

  @override
  State<SplashPreviewScreen> createState() => _SplashPreviewScreenState();
}

class _SplashPreviewScreenState extends State<SplashPreviewScreen> {
  double _progress = 0;

  @override
  Widget build(BuildContext context) {
    const hen = AssetImage('assets/brand/layers/hen_mask.png');
    const eggL = AssetImage('assets/brand/layers/egg_left_mask.png');
    const eggM = AssetImage('assets/brand/layers/egg_mid_mask.png');
    const eggR = AssetImage('assets/brand/layers/egg_right_mask.png');

    return Scaffold(
      appBar: AppBar(title: const Text('Splash preview')),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: SplashMark(
                progress: _progress,
                henMask: hen,
                eggLeft: eggL,
                eggMid: eggM,
                eggRight: eggR,
              ),
            ),
          ),
          Slider(
            value: _progress,
            onChanged: (v) => setState(() => _progress = v),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton(
              onPressed: () => context.go('/splash'),
              child: const Text('Replay live splash'),
            ),
          ),
        ],
      ),
    );
  }
}
