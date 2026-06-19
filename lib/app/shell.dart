import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/constants.dart';
import '../core/design/colors.dart';
import '../core/design/spacing.dart';
import '../core/design/tokens.dart';
import '../core/utils/responsive_layout.dart';
import '../features/profile/providers/profile_notifier.dart';
import '../features/wheel/widgets/giro_hub.dart';
import '../shared/models/user_profile.dart';

/// Adaptive shell — bottom nav on mobile, 280px sidebar on desktop (≥900px).
class MainShell extends ConsumerWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  static const int giroTabIndex = 2;

  static const _destinations = [
    _NavDestination(
      index: 0,
      route: '/contacts',
      icon: Icons.favorite_outline,
      selectedIcon: Icons.favorite,
      label: 'People',
    ),
    _NavDestination(
      index: 1,
      route: '/status',
      icon: Icons.circle_outlined,
      selectedIcon: Icons.circle,
      label: 'Status',
    ),
    _NavDestination(
      index: 2,
      route: '/',
      icon: null,
      selectedIcon: null,
      label: 'Giro',
      isGiro: true,
    ),
    _NavDestination(
      index: 3,
      route: '/stats',
      icon: Icons.insights_outlined,
      selectedIcon: Icons.insights,
      label: 'Stats',
    ),
    _NavDestination(
      index: 4,
      route: '/profile',
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
      label: 'You',
      isProfile: true,
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = _calculateCurrentIndex(context);
    final profile = ref.watch(profileNotifierProvider).value;
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final isDark = AppColors.isDark(context);

    if (isDesktop) {
      return Scaffold(
        backgroundColor: AppColors.pageBackground(context),
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DesktopSidebar(
              currentIndex: currentIndex,
              profile: profile,
              isDark: isDark,
              onSelect: (route) => context.go(route),
            ),
            Expanded(
              child: ColoredBox(
                color: AppColors.pageBackground(context),
                child: child,
              ),
            ),
          ],
        ),
      );
    }

    final compactLabels = ResponsiveLayout.useCompactBottomNav(context);

    return Scaffold(
      backgroundColor: AppColors.pageBackground(context),
      body: child,
      bottomNavigationBar: NavigationBar(
        backgroundColor: isDark
            ? AppColors.darkNavBarBackground
            : AppColors.navBarBackground,
        indicatorColor: AppColors.softTeal,
        elevation: 8,
        shadowColor: AppColors.main.withValues(alpha: 0.12),
        height: AppTokens.navBarHeight,
        labelBehavior: compactLabels
            ? NavigationDestinationLabelBehavior.onlyShowSelected
            : NavigationDestinationLabelBehavior.alwaysShow,
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          final dest = _destinations.firstWhere((d) => d.index == index);
          context.go(dest.route);
        },
        destinations: _destinations
            .map(
              (d) => NavigationDestination(
                icon: _navIcon(d, profile, selected: false),
                selectedIcon: _navIcon(d, profile, selected: true),
                label: d.label,
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _navIcon(
    _NavDestination dest,
    UserProfile? profile, {
    required bool selected,
  }) {
    if (dest.isGiro) {
      return _GiroNavIcon(selected: selected);
    }
    if (dest.isProfile) {
      return _ProfileNavIcon(profile: profile, selected: selected);
    }
    return Icon(selected ? dest.selectedIcon : dest.icon);
  }

  int _calculateCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/settings')) return 4;
    if (location == '/') return giroTabIndex;
    if (location.startsWith('/contacts')) return 0;
    if (location.startsWith('/status')) return 1;
    if (location.startsWith('/stats')) return 3;
    if (location.startsWith('/profile')) return 4;
    return giroTabIndex;
  }
}

class _DesktopSidebar extends StatelessWidget {
  final int currentIndex;
  final UserProfile? profile;
  final bool isDark;
  final ValueChanged<String> onSelect;

  const _DesktopSidebar({
    required this.currentIndex,
    required this.profile,
    required this.isDark,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isDark ? AppColors.darkDivider : AppColors.grey200;

    return SizedBox(
      width: AppTokens.sidebarWidth,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.surface,
          border: Border(right: BorderSide(color: borderColor)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 16,
              offset: const Offset(4, 0),
            ),
          ],
        ),
        child: SafeArea(
          right: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xxs,
                    vertical: AppSpacing.xs,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              AppColors.heroGradientStart,
                              AppColors.heroGradientEnd,
                            ],
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'G',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              Constants.appName,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            Text(
                              Constants.tagline,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppColors.textMuted(context),
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                ...MainShell._destinations.map((dest) {
                  final selected = dest.index == currentIndex;
                  return _SidebarNavItem(
                    destination: dest,
                    profile: profile,
                    selected: selected,
                    onTap: () => onSelect(dest.route),
                  );
                }),
                const Spacer(),
                _SidebarNavItem(
                  destination: const _NavDestination(
                    index: -1,
                    route: '/settings',
                    icon: Icons.settings_outlined,
                    selectedIcon: Icons.settings,
                    label: 'Settings',
                  ),
                  profile: profile,
                  selected: false,
                  onTap: () => onSelect('/settings'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SidebarNavItem extends StatelessWidget {
  final _NavDestination destination;
  final UserProfile? profile;
  final bool selected;
  final VoidCallback onTap;

  const _SidebarNavItem({
    required this.destination,
    required this.profile,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected
        ? (AppColors.isDark(context)
            ? AppColors.darkDivider
            : AppColors.softTeal)
        : Colors.transparent;
    final fg = selected ? AppColors.main : AppColors.textMuted(context);

    Widget icon;
    if (destination.isGiro) {
      icon = GiroHub(
        isSpinning: false,
        size: selected ? 28 : 24,
      );
    } else if (destination.isProfile) {
      icon = CircleAvatar(
        radius: 14,
        backgroundImage: profile?.avatarUrl != null
            ? NetworkImage(profile!.avatarUrl!) as ImageProvider
            : null,
        backgroundColor: selected ? AppColors.orange : AppColors.main,
        child: profile?.avatarUrl == null
            ? const Icon(Icons.person, size: 16, color: Colors.white)
            : null,
      );
    } else {
      icon = Icon(
        selected ? destination.selectedIcon : destination.icon,
        size: 22,
        color: fg,
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTokens.radiusSm),
          child: SizedBox(
            height: AppTokens.minTouchTarget,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              child: Row(
                children: [
                  SizedBox(width: 32, child: Center(child: icon)),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    destination.label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w500,
                          color: fg,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavDestination {
  final int index;
  final String route;
  final IconData? icon;
  final IconData? selectedIcon;
  final String label;
  final bool isGiro;
  final bool isProfile;

  const _NavDestination({
    required this.index,
    required this.route,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    this.isGiro = false,
    this.isProfile = false,
  });
}

class _GiroNavIcon extends StatelessWidget {
  final bool selected;

  const _GiroNavIcon({required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: selected
          ? BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.orange.withValues(alpha: 0.4),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            )
          : null,
      child: GiroHub(
        isSpinning: false,
        size: selected ? 38 : 34,
      ),
    );
  }
}

class _ProfileNavIcon extends StatelessWidget {
  final UserProfile? profile;
  final bool selected;

  const _ProfileNavIcon({required this.profile, required this.selected});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 13,
      backgroundImage: profile?.avatarUrl != null
          ? NetworkImage(profile!.avatarUrl!) as ImageProvider
          : null,
      backgroundColor: selected ? AppColors.orange : AppColors.main,
      child: profile?.avatarUrl == null
          ? const Icon(
              Icons.person,
              size: 16,
              color: Colors.white,
            )
          : null,
    );
  }
}
