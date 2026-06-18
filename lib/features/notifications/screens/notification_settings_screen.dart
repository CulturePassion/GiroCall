import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/colors.dart';
import '../../../core/design/spacing.dart';
import '../../../core/constants.dart';
import '../../../core/utils/screen_padding.dart';
import '../../../shared/models/user_settings.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/responsive_page.dart';
import '../../../shared/widgets/primary_button.dart';
import '../providers/notification_provider.dart';
import '../providers/settings_repository_provider.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  bool _isSaving = false;
  int _dailyCallGoal = Constants.defaultDailyCallGoal;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSavedSettings());
  }

  Future<void> _loadSavedSettings() async {
    final repo = ref.read(settingsRepositoryProvider);
    final settings = await repo.fetchSettings();
    if (!mounted || settings == null) return;

    setState(() => _dailyCallGoal = settings.dailyCallGoal);

    if (settings.dailyReminderTime != null) {
      ref.read(reminderTimeProvider.notifier).state =
          settings.dailyReminderTime!;
      ref.read(reminderEnabledProvider.notifier).state = true;

      final service = ref.read(notificationServiceProvider);
      if (service.supportsLocalNotifications) {
        await service.scheduleDailyReminder(settings.dailyReminderTime!);
      }
    }
  }

  Future<void> _toggle(bool value) async {
    final notifier = ref.read(reminderEnabledProvider.notifier);
    final time = ref.read(reminderTimeProvider);
    final service = ref.read(notificationServiceProvider);

    notifier.state = value;

    if (value) {
      if (service.supportsLocalNotifications) {
        final granted = await service.requestPermissions();
        if (!granted) {
          notifier.state = false;
          if (mounted) {
            _showMessage(
              'Notification permission is required. Enable notifications '
              'in your device settings, then try again.',
            );
          }
          return;
        }
        await service.scheduleDailyReminder(time);
      } else if (mounted) {
        _showMessage(
          'Reminder preference saved. Local notifications are available on '
          'iOS and Android — use the mobile app for daily nudges.',
        );
      }
    } else {
      await service.cancelDailyReminder();
    }

    await _save(time, enabled: value);
  }

  Future<void> _pickTime() async {
    final current = ref.read(reminderTimeProvider);
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
    );

    if (picked != null) {
      final now = DateTime.now();
      final newTime = DateTime(
        now.year,
        now.month,
        now.day,
        picked.hour,
        picked.minute,
      );
      ref.read(reminderTimeProvider.notifier).state = newTime;

      if (ref.read(reminderEnabledProvider)) {
        await ref
            .read(notificationServiceProvider)
            .scheduleDailyReminder(newTime);
        await _save(newTime, enabled: true);
      }
    }
  }

  Future<void> _save(DateTime time, {required bool enabled}) async {
    setState(() => _isSaving = true);
    try {
      final repo = ref.read(settingsRepositoryProvider);
      final userId = repo.userId;
      if (userId == null) return;

      final existing = await repo.fetchSettings();
      final base = existing ??
          UserSettings(
            userId: userId,
            dailyReminderTime: time,
            dailyCallGoal: _dailyCallGoal,
          );
      await repo.upsertSettings(
        base.copyWith(
          dailyReminderTime: enabled ? time : null,
          dailyCallGoal: _dailyCallGoal,
          timezoneOffsetMinutes: DateTime.now().timeZoneOffset.inMinutes,
        ),
      );
      ref.invalidate(userSettingsProvider);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final enabled = ref.watch(reminderEnabledProvider);
    final time = ref.watch(reminderTimeProvider);
    final service = ref.watch(notificationServiceProvider);

    return AppScaffold(
      title: 'Reminders',
      responsiveWidth: ResponsivePageWidth.form,
      body: ResponsivePage(
        width: ResponsivePageWidth.form,
        scrollable: true,
        padding: ScreenPadding.contactsPane(context).copyWith(
          bottom: ScreenPadding.bottomNavClearance(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!service.supportsLocalNotifications) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.secondaryBlue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.secondaryBlue),
                ),
                child: const Text(
                  'On web, your reminder time is saved to your account. '
                  'Install the iOS or Android app for on-device daily notifications.',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Card(
              child: SwitchListTile(
                title: const Text('Daily reminder'),
                subtitle: const Text(
                  'Get a gentle nudge to spin the wheel each day.',
                ),
                activeThumbColor: AppColors.primaryTeal,
                value: enabled,
                onChanged: _toggle,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                title: const Text('Reminder time'),
                subtitle: Text(
                  '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                ),
                trailing: const Icon(Icons.access_time),
                onTap: _pickTime,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily call goal: $_dailyCallGoal',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'How many people you aim to reconnect with each day.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Slider(
                      value: _dailyCallGoal.toDouble(),
                      min: 1,
                      max: 5,
                      divisions: 4,
                      activeColor: AppColors.primaryTeal,
                      label: '$_dailyCallGoal',
                      onChanged: (value) {
                        setState(() => _dailyCallGoal = value.round());
                      },
                      onChangeEnd: (_) async {
                        if (ref.read(reminderEnabledProvider)) {
                          await _save(time, enabled: true);
                        } else {
                          await _save(time, enabled: false);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: 'Done',
              onPressed: () => context.pop(),
              isLoading: _isSaving,
            ),
          ],
        ),
      ),
    );
  }
}
