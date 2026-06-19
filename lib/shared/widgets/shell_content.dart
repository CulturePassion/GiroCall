import 'package:flutter/material.dart';

import '../../core/utils/responsive_layout.dart';

/// Centers shell tab content on wide viewports so lists and forms stay readable.
class ShellContent extends StatelessWidget {
  final Widget child;
  final bool constrainWidth;

  const ShellContent({
    super.key,
    required this.child,
    this.constrainWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!constrainWidth || !ResponsiveLayout.isDesktop(context)) {
      return child;
    }

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: ResponsiveLayout.contentMaxWidth(context),
        ),
        child: child,
      ),
    );
  }
}
