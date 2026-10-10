import 'package:flutter/material.dart';

import 'content_frame.dart';
import 'layout_scope.dart';
import 'page_layout.dart';

/// Marks a route whose body is already an [AppPage], so a router wrapper
/// does not add a second frame.
class AppPageMarker extends InheritedWidget {
  const AppPageMarker({required super.child, super.key});

  static bool isUnder(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppPageMarker>() != null;
  }

  @override
  bool updateShouldNotify(AppPageMarker oldWidget) => false;
}

/// Default page scaffold. Screens pass a [PageLayout] preset and a body.
class AppPage extends StatelessWidget {
  const AppPage({
    required this.body,
    this.title,
    this.actions,
    this.leading,
    this.floatingActionButton,
    this.bottom,
    this.preset = PageLayout.standard,
    this.primary = true,
    this.scroll = false,
    this.frame = true,
    super.key,
  });

  final Widget body;
  final String? title;
  final List<Widget>? actions;
  final Widget? leading;
  final Widget? floatingActionButton;
  final Widget? bottom;
  final PageLayout preset;
  final bool primary;
  final bool scroll;
  final bool frame;

  @override
  Widget build(BuildContext context) {
    final layout = context.layout;
    final showAppBar = primary && title != null;
    Widget content = body;
    if (scroll) {
      content = SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.only(
          bottom: ContentFrame.scrollBottomInset(context),
        ),
        child: content,
      );
    }
    if (frame && preset != PageLayout.fullBleed) {
      content = ContentFrame(preset: preset, child: content);
    }

    return AppPageMarker(
      child: Scaffold(
        primary: primary,
        appBar: showAppBar
            ? AppBar(
                toolbarHeight: layout.isShort ? 48 : kToolbarHeight,
                leading: leading,
                title: Text(title!),
                actions: actions,
              )
            : null,
        body: content,
        floatingActionButton: floatingActionButton,
        bottomNavigationBar: bottom,
      ),
    );
  }
}
