import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/design/colors.dart';
import '../../core/design/spacing.dart';
import '../../core/design/tokens.dart';

/// Live date + time strip for hub screens.
class LiveClockHeader extends StatefulWidget {
  final bool lightText;

  const LiveClockHeader({super.key, this.lightText = false});

  @override
  State<LiveClockHeader> createState() => _LiveClockHeaderState();
}

class _LiveClockHeaderState extends State<LiveClockHeader> {
  late DateTime _now;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('EEE, MMM d, yyyy');
    final timeFmt = DateFormat('h:mm a');

    final onLight = widget.lightText;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs + 2,
      ),
      decoration: BoxDecoration(
        color: onLight
            ? Colors.white.withValues(alpha: 0.14)
            : AppColors.cardSurface(context),
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        border: Border.all(
          color: onLight
              ? Colors.white.withValues(alpha: 0.22)
              : AppColors.isDark(context)
                  ? AppColors.darkDivider
                  : AppColors.grey200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.schedule_rounded,
            size: 18,
            color: onLight ? Colors.white : AppColors.main,
          ),
          const SizedBox(width: AppSpacing.xxs),
          Expanded(
            child: Text(
              '${dateFmt.format(_now)} · ${timeFmt.format(_now)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                    color: onLight ? Colors.white : null,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
