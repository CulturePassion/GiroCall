import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/design/colors.dart';
import 'gradient_background.dart';
import 'responsive_page.dart';

/// Visual style for scaffold backgrounds.
enum AppScaffoldVariant {
  standard,
  hero,
}

/// Standard app scaffold with consistent padding, safe areas, and variants.
class AppScaffold extends StatelessWidget {
  final String? title;
  final Widget? body;
  final List<Widget>? actions;
  final bool showBackButton;
  final ResponsivePageWidth? responsiveWidth;
  final AppScaffoldVariant variant;
  final Widget? floatingActionButton;

  const AppScaffold({
    super.key,
    this.title,
    this.body,
    this.actions,
    this.showBackButton = true,
    this.responsiveWidth,
    this.variant = AppScaffoldVariant.standard,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    final isHero = variant == AppScaffoldVariant.hero;
    final pageBg = AppColors.pageBackground(context);

    Widget content = AnnotatedRegion<SystemUiOverlayStyle>(
      value: isHero ? SystemUiOverlayStyle.light : _overlayFor(context),
      child: Scaffold(
        backgroundColor: isHero ? Colors.transparent : pageBg,
        appBar: AppBar(
          backgroundColor: AppColors.main,
          foregroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: showBackButton,
          title: title != null
              ? Text(
                  title!,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                )
              : null,
          actions: actions,
          systemOverlayStyle:
              isHero ? SystemUiOverlayStyle.light : _overlayFor(context),
        ),
        floatingActionButton: floatingActionButton,
        body: isHero
            ? GradientBackground(
                child: SafeArea(
                  child: body ?? const SizedBox.shrink(),
                ),
              )
            : SafeArea(
                child: body ?? const SizedBox.shrink(),
              ),
      ),
    );

    if (responsiveWidth != null) {
      content = ResponsivePage(
        width: responsiveWidth!,
        child: content,
      );
    }

    return content;
  }

  SystemUiOverlayStyle _overlayFor(BuildContext context) {
    return AppColors.isDark(context)
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark;
  }
}
