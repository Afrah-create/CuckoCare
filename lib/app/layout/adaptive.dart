import 'package:flutter/material.dart';

import 'breakpoints.dart';
import 'content_frame.dart';
import 'layout_scope.dart';

/// Columns from the available width and a minimum item width.
class AdaptiveGrid extends StatelessWidget {
  const AdaptiveGrid({
    required this.children,
    this.minItemWidth,
    this.itemHeight = 120,
    super.key,
  });

  final List<Widget> children;
  final double? minItemWidth;
  final double itemHeight;

  @override
  Widget build(BuildContext context) {
    final layout = context.layout;
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = layout.columnsFor(
          constraints.maxWidth,
          minItemWidth: minItemWidth,
        );
        final extent = itemHeight * (layout.isLargeText ? 1.2 : 1);
        return GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: layout.gutter,
            crossAxisSpacing: layout.gutter,
            mainAxisExtent: extent,
          ),
          children: children,
        );
      },
    );
  }
}

/// One or two columns of form fields, with actions kept below the fields.
class AdaptiveForm extends StatelessWidget {
  const AdaptiveForm({
    required this.children,
    this.actions,
    super.key,
  });

  final List<Widget> children;
  final Widget? actions;

  @override
  Widget build(BuildContext context) {
    final layout = context.layout;
    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumns = !layout.isLargeText &&
            constraints.maxWidth >= Breakpoints.formTwoColumnMinWidth;
        final fields = twoColumns
            ? _twoColumns(children, layout.gutter)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final child in children) ...[
                    child,
                    SizedBox(height: layout.gutter),
                  ],
                ],
              );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            fields,
            if (actions != null) ...[
              SizedBox(height: layout.gutter),
              actions!,
            ],
          ],
        );
      },
    );
  }

  Widget _twoColumns(List<Widget> fields, double gap) {
    final rows = <Widget>[];
    for (var i = 0; i < fields.length; i += 2) {
      final left = fields[i];
      final right = i + 1 < fields.length ? fields[i + 1] : const SizedBox();
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: left),
            SizedBox(width: gap),
            Expanded(child: right),
          ],
        ),
      );
      rows.add(SizedBox(height: gap));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: rows,
    );
  }
}

/// A row that wraps onto extra lines when the width is tight.
class AdaptiveWrap extends StatelessWidget {
  const AdaptiveWrap({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final layout = context.layout;
    return Wrap(
      spacing: layout.gutter,
      runSpacing: layout.gutter,
      children: children,
    );
  }
}

/// Dialog constrained to the profile's dialog width.
Future<T?> showAdaptiveDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) {
  final layout = context.layout;
  return showDialog<T>(
    context: context,
    builder: (dialogContext) {
      return Dialog(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: layout.maxDialogWidth,
            maxHeight: layout.size.height * 0.9,
          ),
          child: SingleChildScrollView(child: builder(dialogContext)),
        ),
      );
    },
  );
}

/// Image slot with a bounded aspect ratio and a loading placeholder.
class AdaptiveMedia extends StatelessWidget {
  const AdaptiveMedia({
    required this.child,
    this.aspectRatio = 4 / 3,
    super.key,
  });

  final Widget child;
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: child,
      ),
    );
  }
}

/// Bottom inset helper re-exported for scroll views inside adaptive pages.
double adaptiveScrollBottom(BuildContext context) {
  return ContentFrame.scrollBottomInset(context);
}
