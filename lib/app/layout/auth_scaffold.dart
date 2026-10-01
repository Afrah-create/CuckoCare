import 'package:flutter/material.dart';

import '../theme/theme_context.dart';
import '../widgets/app_logo.dart';
import 'layout_scope.dart';

/// Shared auth layout: brand panel + scrollable form.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    required this.form,
    required this.modeSelector,
    super.key,
  });

  final Widget form;
  final Widget modeSelector;

  @override
  Widget build(BuildContext context) {
    final layout = context.layout;
    final scheme = context.scheme;
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    final sideBySide =
        layout.useTwoPane && !keyboardOpen && layout.size.width >= 640;

    final brandPanel = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primaryContainer.withValues(alpha: 0.7),
            scheme.surfaceContainerHighest.withValues(alpha: 0.5),
          ],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(layout.isCompactHeight ? 16 : 24),
        child: Center(
          child: AppLogo(
            size: layout.isCompactHeight ? AppLogoSize.small : AppLogoSize.medium,
            showWordmark: true,
          ),
        ),
      ),
    );

    final formColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        modeSelector,
        SizedBox(height: layout.isCompactHeight ? 12 : 16),
        form,
      ],
    );

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.only(
                bottom: MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: sideBySide ? 920 : 440,
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(layout.margin),
                      child: sideBySide
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: brandPanel),
                                SizedBox(width: layout.gutter),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: formColumn,
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                brandPanel,
                                SizedBox(height: layout.gutter),
                                formColumn,
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
