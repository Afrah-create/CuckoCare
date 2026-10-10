import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Dev-only window override. Null means the real window.
class LayoutPreview {
  const LayoutPreview({required this.size, this.textScale = 1});

  final Size size;
  final double textScale;
}

final layoutPreviewProvider =
    NotifierProvider<LayoutPreviewNotifier, LayoutPreview?>(
  LayoutPreviewNotifier.new,
);

class LayoutPreviewNotifier extends Notifier<LayoutPreview?> {
  @override
  LayoutPreview? build() => null;

  void setPreview(LayoutPreview? preview) => state = preview;
}

final layoutInspectorProvider =
    NotifierProvider<LayoutInspectorNotifier, bool>(
  LayoutInspectorNotifier.new,
);

class LayoutInspectorNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setEnabled(bool enabled) => state = enabled;
}
