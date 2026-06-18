import 'package:fl_chart/fl_chart.dart';
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

    final statItems = [
      _StatItem('Current streak', '${stats.currentStreak}', 'days',
          Icons.local_fire_department, AppColors.orange),
      _StatItem('Longest streak', '${stats.longestStreak}', 'days',
          Icons.emoji_events_outlined, AppColors.goldenYellow),
      _StatItem('Today\'s goal', '${stats.callsToday}', 'of $dailyGoal',
          Icons.flag_outlined, AppColors.secondaryBlue),
      _StatItem('Total calls', '${stats.totalCalls}', 'calls',
          Icons.phone_in_talk, AppColors.main),
      _StatItem('Reconnected', '${stats.uniqueContactsCalled}', 'people',
          Icons.favorite, AppColors.softPink),
      _StatItem('Avg rating', stats.averageRating.toStringAsFixed(1), 'stars',
          Icons.star_rounded, AppColors.goldenYellow),
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
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth >= 500 ? 3 : 2;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: AppSpacing.xxs,
                    crossAxisSpacing: AppSpacing.xxs,
                    childAspectRatio: crossAxisCount == 3 ? 1.05 : 0.95,
                  ),
                  itemCount: statItems.length,
                  itemBuilder: (context, index) =>
                      _StatCard(item: statItems[index]),
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
            const SizedBox(height: AppSpacing.xs),
            PremiumCard(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xs,
                AppSpacing.sm,
                AppSpacing.xs,
                AppSpacing.xs,
              ),
              child: SizedBox(
                height: 220,
                child: _ActivityChart(
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

class _StatItem {
  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;

  const _StatItem(
    this.label,
    this.value,
    this.unit,
    this.icon,
    this.color,
  );
}

class _StatCard extends StatelessWidget {
  final _StatItem item;

  const _StatCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      accentColor: item.color,
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xxs),
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, color: item.color, size: 22),
          ),
          const Spacer(),
          Text(
            item.value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(item.unit, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(
            item.label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ActivityChart extends StatelessWidget {
  final int today;
  final int week;
  final int month;

  const _ActivityChart({
    required this.today,
    required this.week,
    required this.month,
  });

  @override
  Widget build(BuildContext context) {
    final data = [
      _ChartData('Today', today.toDouble()),
      _ChartData('7 days', week.toDouble()),
      _ChartData('30 days', month.toDouble()),
    ];
    final maxVal = [today, week, month].reduce((a, b) => a > b ? a : b);
    final labelColor = Theme.of(context).colorScheme.onSurfaceVariant;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxVal.toDouble() + 2,
        barTouchData: const BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= data.length) {
                  return const SizedBox();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    data[index].label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: labelColor,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        barGroups: data.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.value,
                width: 40,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(10),
                ),
                gradient: const LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [AppColors.main, AppColors.heroGradientMid],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _ChartData {
  final String label;
  final double value;

  _ChartData(this.label, this.value);
}
