import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_colors.dart';
import '../../../core/constants.dart';
import '../../../core/utils/screen_padding.dart';
import '../../../core/app_spacing.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/glass_surface.dart';
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
      _StatItem(
        label: 'Current streak',
        value: '${stats.currentStreak}',
        unit: 'days',
        icon: Icons.local_fire_department,
        color: AppColors.accentCoral,
      ),
      _StatItem(
        label: 'Longest streak',
        value: '${stats.longestStreak}',
        unit: 'days',
        icon: Icons.emoji_events_outlined,
        color: AppColors.accentCoral,
      ),
      _StatItem(
        label: 'Today\'s goal',
        value: '${stats.callsToday}',
        unit: 'of $dailyGoal',
        icon: Icons.flag_outlined,
        color: AppColors.paletteGold,
      ),
      _StatItem(
        label: 'Total calls',
        value: '${stats.totalCalls}',
        unit: 'calls',
        icon: Icons.phone_in_talk,
        color: AppColors.primaryTeal,
      ),
      _StatItem(
        label: 'Reconnected',
        value: '${stats.uniqueContactsCalled}',
        unit: 'people',
        icon: Icons.people,
        color: AppColors.paletteGold,
      ),
      _StatItem(
        label: 'Avg rating',
        value: stats.averageRating.toStringAsFixed(1),
        unit: 'stars',
        icon: Icons.star,
        color: const Color(0xFFF59E0B),
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
            Text(
              'Nice work staying connected.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth >= 500 ? 3 : 2;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: crossAxisCount == 3 ? 1.3 : 1.1,
                  ),
                  itemCount: statItems.length,
                  itemBuilder: (context, index) =>
                      _StatCard(item: statItems[index]),
                );
              },
            ),
            const SizedBox(height: 20),
            Text(
              'Recent activity',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            GlassSurface(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xxs,
                AppSpacing.xs,
                AppSpacing.xxs,
                AppSpacing.xxs,
              ),
              borderRadius: AppSpacing.radiusLg,
              child: SizedBox(
                height: 200,
                child: _ActivityChart(
                  today: stats.callsToday,
                  week: stats.callsThisWeek,
                  month: stats.callsThisMonth,
                ),
              ),
            ),
            SizedBox(height: ScreenPadding.bottomNavClearance(context) - 56),
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

  const _StatItem({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
  });
}

class _StatCard extends StatelessWidget {
  final _StatItem item;

  const _StatCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      padding: const EdgeInsets.all(AppSpacing.xs + 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xxs),
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Icon(item.icon, color: item.color, size: 20),
          ),
          const Spacer(),
          Text(
            item.value,
            style:
                Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 24),
          ),
          Text(item.unit, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 2),
          Text(
            item.label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
            maxLines: 1,
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

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxVal.toDouble() + 1,
        barTouchData: const BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          leftTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
                    style: Theme.of(context).textTheme.bodySmall,
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
                color: AppColors.paletteTeal,
                width: 36,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
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
