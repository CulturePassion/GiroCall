import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/design/colors.dart';
import '../../core/design/spacing.dart';
import '../../core/design/tokens.dart';
import '../../features/stats/providers/stats_provider.dart';
import 'premium_card.dart';
import 'streak_ring.dart';

/// Compact stats overview for web dashboard beside the wheel.
class StatsDashboardPanel extends StatelessWidget {
  final UserStats stats;
  final int dailyGoal;

  const StatsDashboardPanel({
    super.key,
    required this.stats,
    required this.dailyGoal,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PremiumCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              StreakRing(
                streak: stats.currentStreak,
                goal: stats.longestStreak > 0 ? stats.longestStreak : null,
                size: 80,
                label: 'day streak',
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _MetricLine(
                      icon: Icons.favorite,
                      color: AppColors.pinkMagenta,
                      label: 'Reconnected',
                      value: '${stats.uniqueContactsCalled}',
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    _MetricLine(
                      icon: Icons.phone_in_talk,
                      color: AppColors.vibrantGreen,
                      label: 'Total calls',
                      value: '${stats.totalCalls}',
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    _MetricLine(
                      icon: Icons.flag_outlined,
                      color: AppColors.softBluePurple,
                      label: 'Today',
                      value: '${stats.callsToday} / $dailyGoal',
                    ),
                  ],
                ),
              ),
            ],
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Calls this week',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                height: 140,
                child: ActivityBarChart(
                  today: stats.callsToday,
                  week: stats.callsThisWeek,
                  month: stats.callsThisMonth,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class StatTile extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;

  const StatTile({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      accentColor: color,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs + 2,
      ),
      borderRadius: AppTokens.radiusMd,
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppTokens.radiusSm),
            ),
            child: Icon(icon, color: color, size: 17),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: value,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  height: 1.1,
                                ),
                      ),
                      if (unit.isNotEmpty)
                        TextSpan(
                          text: ' $unit',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textMuted(context),
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
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
    );
  }
}

class ActivityBarChart extends StatelessWidget {
  final int today;
  final int week;
  final int month;
  final double barWidth;

  const ActivityBarChart({
    super.key,
    required this.today,
    required this.week,
    required this.month,
    this.barWidth = 28,
  });

  @override
  Widget build(BuildContext context) {
    final data = [
      _ChartPoint('Today', today.toDouble()),
      _ChartPoint('7 days', week.toDouble()),
      _ChartPoint('30 days', month.toDouble()),
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
                  padding: const EdgeInsets.only(top: AppSpacing.xxs),
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
                width: barWidth,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(10),
                ),
                gradient: const LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    AppColors.vibrantGreen,
                    AppColors.goldenYellowOrange
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _MetricLine extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  const _MetricLine({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: AppSpacing.xxs),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}

class _ChartPoint {
  final String label;
  final double value;

  _ChartPoint(this.label, this.value);
}
