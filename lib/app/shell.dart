import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/design/colors.dart';
import '../features/profile/providers/profile_notifier.dart';
import '../features/wheel/widgets/giro_hub.dart';
import '../shared/models/user_profile.dart';

/// Premium bottom navigation — Giro is the center (hero) tab.
class MainShell extends ConsumerWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  static const int giroTabIndex = 2;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = _calculateCurrentIndex(context);
    final profile = ref.watch(profileNotifierProvider).value;
    final isDark = AppColors.isDark(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        backgroundColor:
            isDark ? AppColors.darkNavBarBackground : AppColors.navBarBackground,
        indicatorColor: AppColors.softTeal,
        elevation: 8,
        shadowColor: AppColors.main.withValues(alpha: 0.12),
        height: 72,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          final location = switch (index) {
            0 => '/contacts',
            1 => '/status',
            2 => '/',
            3 => '/stats',
            4 => '/profile',
            _ => '/',
          };
          context.go(location);
        },
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite),
            label: 'People',
          ),
          const NavigationDestination(
            icon: Icon(Icons.circle_outlined),
            selectedIcon: Icon(Icons.circle),
            label: 'Status',
          ),
          const NavigationDestination(
            icon: _GiroNavIcon(selected: false),
            selectedIcon: _GiroNavIcon(selected: true),
            label: 'Giro',
          ),
          const NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'Stats',
          ),
          NavigationDestination(
            icon: _ProfileNavIcon(profile: profile, selected: false),
            selectedIcon: _ProfileNavIcon(profile: profile, selected: true),
            label: 'You',
          ),
        ],
      ),
    );
  }

  int _calculateCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location == '/') return giroTabIndex;
    if (location.startsWith('/contacts')) return 0;
    if (location.startsWith('/status')) return 1;
    if (location.startsWith('/stats')) return 3;
    if (location.startsWith('/profile')) return 4;
    return giroTabIndex;
  }
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