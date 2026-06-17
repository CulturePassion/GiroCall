import 'package:flutter/material.dart';

import '../../core/app_spacing.dart';
import 'gradient_background.dart';
import 'responsive_page.dart';

/// Consistent scaffold with colorful gradient + optional glass app bar.
class AppScaffold extends StatelessWidget {
  final String? title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final bool showBackButton;
  final PreferredSizeWidget? bottom;
  final bool useGradientBackground;
  final ResponsivePageWidth? responsiveWidth;
  final bool responsiveScrollable;

  const AppScaffold({
    super.key,
    this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.showBackButton = true,
    this.bottom,
    this.useGradientBackground = true,
    this.responsiveWidth = ResponsivePageWidth.content,
    this.responsiveScrollable = false,
  });

  @override
  Widget build(BuildContext context) {
    var resolvedBody = body;
    if (responsiveWidth != null) {
      resolvedBody = ResponsivePage(
        width: responsiveWidth!,
        scrollable: responsiveScrollable,
        padding: EdgeInsets.zero,
        child: body,
      );
    }

    final content = useGradientBackground
        ? GradientBackground(child: resolvedBody)
        : resolvedBody;

    return Scaffold(
      extendBodyBehindAppBar: title != null,
      appBar: title == null
          ? null
          : AppBar(
              title: Text(title!),
              actions: actions,
              automaticallyImplyLeading: showBackButton,
              bottom: bottom,
            ),
      body: SafeArea(child: content),
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}

/// Minimum-size icon button for 44×44 touch targets.
class TouchIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Widget? child;

  const TouchIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: child ?? Icon(icon),
      tooltip: tooltip,
      onPressed: onPressed,
      constraints: const BoxConstraints(
        minWidth: AppSpacing.minTouchTarget,
        minHeight: AppSpacing.minTouchTarget,
      ),
    );
  }
}
