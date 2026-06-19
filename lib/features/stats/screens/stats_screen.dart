import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants.dart';
import '../../../core/design/colors.dart';
import '../../../core/design/microcopy.dart';
import '../../../core/design/spacing.dart';
import '../../../core/design/tokens.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/utils/screen_padding.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/premium_card.dart';
import '../../../shared/widgets/shell_content.dart';
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
    final dailyGoal =
        settingsAsync.value?.dailyCallGoal ?? Constants.defaultDailyCallGoal;
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final goalProgress =
        dailyGoal > 0 ? (stats.callsToday / dailyGoal).clamp(0.0, 1.0) : 0.0;

    final secondaryStats = [
      (
        'Longest streak',
        '${stats.longestStreak}',
        'days',
        Icons.emoji_events_outlined,
        AppColors.goldenYellow,
      ),
      (
        'Total calls',
        '${stats.totalCalls}',
        '',
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

    final heroCard = PremiumCard(
      accentColor: AppColors.orange,
      padding: const EdgeInsets.all(AppSpacing.sm),
      borderRadius: AppTokens.radiusMd,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          StreakRing(
            streak: stats.currentStreak,
            goal: stats.longestStreak > 0 ? stats.longestStreak : null,
            size: 68,
            label: 'day streak',
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stats.currentStreak > 0
                      ? 'You\'re on a roll!'
                      : 'Start your streak today',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  Microcopy.statsEncouragement,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted(context),
                        height: 1.35,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    const Icon(
                      Icons.flag_outlined,
                      size: 14,
                      color: AppColors.secondaryBlue,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${stats.callsToday} of $dailyGoal today',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                  child: LinearProgressIndicator(
                    value: goalProgress,
                    minHeight: 6,
                    backgroundColor: AppColors.isDark(context)
                        ? AppColors.darkDivider
                        : AppColors.grey200,
                    color: AppColors.secondaryBlue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    final metricsGrid = LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 520 ? 2 : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: AppSpacing.xs,
            crossAxisSpacing: AppSpacing.xs,
            childAspectRatio: crossAxisCount == 1 ? 4.8 : 3.1,
          ),
          itemCount: secondaryStats.length,
          itemBuilder: (context, index) {
            final item = secondaryStats[index];
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
    );

    final activityCard = PremiumCard(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xs,
        AppSpacing.sm,
        AppSpacing.xs,
        AppSpacing.xs,
      ),
      borderRadius: AppTokens.radiusMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            Microcopy.statsActivity,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          SizedBox(
            height: isDesktop ? 140 : 128,
            child: ActivityBarChart(
              today: stats.callsToday,
              week: stats.callsThisWeek,
              month: stats.callsThisMonth,
              barWidth: isDesktop ? 32 : 24,
            ),
          ),
        ],
      ),
    );

    return AppScaffold(
      title: 'Your Stats',
      showBackButton: false,
      body: ShellContent(
        child: SingleChildScrollView(
          padding: ScreenPadding.all(context).copyWith(
            top: AppSpacing.xxs,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                Microcopy.statsGreeting,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textMuted(context),
                      height: 1.4,
                    ),
              ),
              const SizedBox(height: AppSpacing.xs),
              if (isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          heroCard,
                          const SizedBox(height: AppSpacing.xs),
                          metricsGrid,
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      flex: 4,
                      child: activityCard,
                    ),
                  ],
                )
              else ...[
                heroCard,
                const SizedBox(height: AppSpacing.xs),
                metricsGrid,
                const SizedBox(height: AppSpacing.sm),
                activityCard,
              ],
              SizedBox(height: ScreenPadding.bottomNavClearance(context)),
            ],
          ),
        ),
      ),
    );
  }
}
