import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants.dart';
import '../../../core/design/microcopy.dart';
import '../../../core/theme/theme_mode_provider.dart';
import '../../../core/utils/screen_padding.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/settings_section.dart';

/// App settings — appearance, notifications, and about.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return AppScaffold(
      title: 'Settings',
      body: ListView(
        padding: ScreenPadding.all(context),
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
          const SizedBox(height: 20),
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
          const SizedBox(height: 20),
          SettingsSection(
            title: 'ACCOUNT',
            children: [
              SettingsTile(
                icon: Icons.account_circle_outlined,
                title: 'My Profile',
                subtitle: 'Manage your personal info',
                onTap: () => context.push('/profile'),
              ),
              SettingsTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy',
                subtitle: 'Review privacy settings',
                onTap: () => context.push('/profile'), // Link to profile privacy settings
              ),
            ],
          ),
          const SizedBox(height: 20),
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
                subtitle: '1.2.1',
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
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