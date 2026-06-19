import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants.dart';
import '../../../core/design/microcopy.dart';
import '../../../core/design/spacing.dart';
import '../../../core/theme/theme_mode_provider.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/utils/screen_padding.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/responsive_page.dart';
import '../../../shared/widgets/settings_section.dart';
import '../../../shared/widgets/shell_content.dart';

/// App settings — appearance, notifications, and about.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return AppScaffold(
      title: 'Settings',
      showBackButton: false,
      body: ShellContent(
        child: ResponsivePage(
          width: ResponsivePageWidth.content,
          scrollable: true,
          padding: ScreenPadding.contactsPane(context).copyWith(
            bottom: ScreenPadding.bottomNavClearance(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SettingsSection(
                title: 'APPEARANCE',
                children: [
                  SettingsTile(
                    icon: Icons.dark_mode_outlined,
                    title: 'Theme',
                    subtitle: _themeLabel(themeMode),
                    onTap: () => _showThemePicker(context, ref),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              SettingsSection(
                title: 'NOTIFICATIONS',
                children: [
                  SettingsTile(
                    icon: Icons.notifications_active_outlined,
                    title: 'Daily reminders',
                    subtitle: 'Spin nudges and call goals',
                    onTap: () => context.push('/settings/notifications'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              SettingsSection(
                title: 'ACCOUNT',
                children: [
                  SettingsTile(
                    icon: Icons.person_outline,
                    title: 'You',
                    subtitle: 'Profile hub — card, edit, and shortcuts',
                    onTap: () => context.go('/profile'),
                  ),
                  SettingsTile(
                    icon: Icons.badge_outlined,
                    title: 'My /me page',
                    subtitle: 'Public link, username, and sharing',
                    onTap: () => context.go('/profile/card'),
                  ),
                  SettingsTile(
                    icon: Icons.account_circle_outlined,
                    title: 'Account',
                    subtitle: 'Email, password, sign out, delete account',
                    onTap: () => context.push('/settings/account'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              const SettingsSection(
                title: 'ABOUT',
                children: [
                  SettingsTile(
                    icon: Icons.favorite_outlined,
                    title: 'Made with love',
                    subtitle: Microcopy.madeWithLove,
                  ),
                  SettingsTile(
                    icon: Icons.info_outline,
                    title: Constants.appName,
                    subtitle: 'Stay connected with those who matter',
                  ),
                  SettingsTile(
                    icon: Icons.verified_outlined,
                    title: 'Version',
                    subtitle: '2.0.0',
                  ),
                ],
              ),
              SizedBox(height: ResponsiveLayout.horizontalPadding(context)),
            ],
          ),
        ),
      ),
    );
  }

  String _themeLabel(ThemeMode mode) => switch (mode) {
        ThemeMode.light => 'Light',
        ThemeMode.dark => 'Dark',
        ThemeMode.system => 'System default',
      };

  Future<void> _showThemePicker(BuildContext context, WidgetRef ref) async {
    final current = ref.read(themeModeProvider);
    final selected = await showModalBottomSheet<ThemeMode>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Choose theme',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
              ),
              _ThemeOption(
                icon: Icons.brightness_auto_outlined,
                label: 'System default',
                selected: current == ThemeMode.system,
                onTap: () => Navigator.pop(context, ThemeMode.system),
              ),
              _ThemeOption(
                icon: Icons.light_mode_outlined,
                label: 'Light',
                selected: current == ThemeMode.light,
                onTap: () => Navigator.pop(context, ThemeMode.light),
              ),
              _ThemeOption(
                icon: Icons.dark_mode_outlined,
                label: 'Dark',
                selected: current == ThemeMode.dark,
                onTap: () => Navigator.pop(context, ThemeMode.dark),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );

    if (selected != null) {
      await ref.read(themeModeProvider.notifier).setThemeMode(selected);
    }
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: selected
          ? const Icon(Icons.check_circle, color: Color(0xFF0D9488))
          : null,
      onTap: onTap,
    );
  }
}
