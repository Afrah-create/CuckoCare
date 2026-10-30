import 'package:flutter/material.dart';

import '../../../app/layout/layout_scope.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import 'auth_header.dart';

class AuthCard extends StatelessWidget {
  const AuthCard({
    required this.header,
    required this.modeSwitch,
    required this.body,
    super.key,
  });

  final Widget modeSwitch;
  final Widget body;
  final String header;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final layout = context.layout;
    final compact = authHeaderCompact(context);
    final padding = layout.isCompactHeight ? 20.0 : 24.0;
    final twoColumn = layout.useTwoPane && !compact;

    final headerWidget = AuthHeader(compact: compact, tagline: header);

    final formColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        modeSwitch,
        SizedBox(height: layout.isCompactHeight ? AppSpacing.sm : AppSpacing.md),
        body,
      ],
    );

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: twoColumn ? 720 : 440,
      ),
      child: Material(
        color: scheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusAuthCard),
          side: BorderSide(color: scheme.outlineVariant),
        ),
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: twoColumn
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: headerWidget),
                    SizedBox(width: layout.gutter * 2),
                    Expanded(child: formColumn),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    headerWidget,
                    SizedBox(
                      height: layout.isCompactHeight
                          ? AppSpacing.md
                          : AppSpacing.lg,
                    ),
                    formColumn,
                  ],
                ),
        ),
      ),
    );
  }
}
