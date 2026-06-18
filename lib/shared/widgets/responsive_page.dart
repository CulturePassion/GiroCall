import 'package:flutter/material.dart';

import '../../core/utils/responsive_layout.dart';

enum ResponsivePageWidth { form, content, full }

/// Centers content with web-friendly max-width ratios.
class ResponsivePage extends StatelessWidget {
  final Widget child;
  final ResponsivePageWidth width;
  final EdgeInsetsGeometry? padding;
  final bool scrollable;
  final CrossAxisAlignment align;

  const ResponsivePage({
    super.key,
    required this.child,
    this.width = ResponsivePageWidth.content,
    this.padding,
    this.scrollable = false,
    this.align = CrossAxisAlignment.stretch,
  });

  @override
  Widget build(BuildContext context) {
    final maxWidth = switch (width) {
      ResponsivePageWidth.form => ResponsiveLayout.formMaxWidth(context),
      ResponsivePageWidth.content => ResponsiveLayout.contentMaxWidth(context),
      ResponsivePageWidth.full => double.infinity,
    };

    final resolvedPadding = padding ?? ResponsiveLayout.pagePadding(context);

    Widget content = Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: resolvedPadding,
          child: child,
        ),
      ),
    );

    if (scrollable) {
      content = SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: content,
      );
    }

    return content;
  }
}
