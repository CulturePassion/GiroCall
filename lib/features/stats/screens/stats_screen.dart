import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants.dart';
import '../../../core/design/colors.dart';
import '../../../core/design/microcopy.dart';
import '../../../core/design/spacing.dart';
import '../../../core/utils/screen_padding.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/page_header.dart';
import '../../../shared/widgets/premium_card.dart';
import '../../../shared/widgets/stats_widgets.dart';
import '../../../shared/widgets/streak_ring.dart';
import '../../notifications/providers/settings_repository_provider.dart';
import '../providers/stats_provider.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statsProvider);
    final settingsAsync = ref.watch(userSettingsProvider);
    final dailyGoal = settingsAsync.value?.dailyCallGoal ??
        Constants.defaultDailyCallGoal;

    final statItems = [
      (
        'Current streak',
        '${stats.currentStreak}',
        'days',
        Icons.local_fire_department,
        AppColors.orange,
      ),
      (
        'Longest streak',
        '${stats.longestStreak}',
        'days',
        Icons.emoji_events_outlined,
        AppColors.goldenYellow,
      ),
      (
        'Today\'s goal',
        '${stats.callsToday}',
        'of $dailyGoal',
        Icons.flag_outlined,
        AppColors.secondaryBlue,
      ),
      (
        'Total calls',
        '${stats.totalCalls}',
        'calls',
        Icons.phone_in_talk,
        AppColors.main,
      ),
      (
        'Reconnected',
        '${stats.uniqueContactsCalled}',
        'people',
        Icons.favorite,
        AppColors.softPink,
      ),
      (
        'Avg rating',
        stats.averageRating.toStringAsFixed(1),
        'stars',
        Icons.star_rounded,
        AppColors.goldenYellow,
      ),
    ];

    return AppScaffold(
      title: 'Your Stats',
      showBackButton: false,
      body: SingleChildScrollView(
        padding: ScreenPadding.all(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const PageHeader(
              title: Microcopy.statsGreeting,
              subtitle: Microcopy.statsEncouragement,
            ),
            PremiumCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  StreakRing(
                    streak: stats.currentStreak,
                    goal: stats.longestStreak > 0 ? stats.longestStreak : null,
                    size: 96,
                    label: 'day streak',
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stats.currentStreak > 0
                              ? 'You\'re on a roll!'
                              : 'Start your streak today',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          'Every call is a little act of love. Keep going.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth >= 500 ? 3 : 2;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: AppSpacing.sm,
                    crossAxisSpacing: AppSpacing.sm,
                    childAspectRatio: crossAxisCount == 3 ? 1.05 : 0.95,
                  ),
                  itemCount: statItems.length,
                  itemBuilder: (context, index) {
                    final item = statItems[index];
                    return StatTile(
                      label: item.$1,
                      value: item.$2,
                      unit: item.$3,
                      icon: item.$4,
                      color: item.$5,
                    );
                  },
                );
              },
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              Microcopy.statsActivity,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            PremiumCard(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.sm,
              ),
              child: SizedBox(
                height: 220,
                child: ActivityBarChart(
                  today: stats.callsToday,
                  week: stats.callsThisWeek,
                  month: stats.callsThisMonth,
                ),
              ),
            ),
            SizedBox(height: ScreenPadding.bottomNavClearance(context)),
          ],
        ),
      ),
    );
  }
}