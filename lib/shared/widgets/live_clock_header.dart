import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/design/colors.dart';

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
    final dateFmt = DateFormat('EEE, MMM d');
    final timeFmt = DateFormat('h:mm a');

    final onLight = widget.lightText;

    // Small and plain style
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 2,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${dateFmt.format(_now)}  ·  ${timeFmt.format(_now)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w400,
                  color: onLight
                      ? Colors.white.withValues(alpha: 0.9)
                      : AppColors.textSecondary,
                  letterSpacing: 0.3,
                ),
          ),
        ],
      ),
    );
  }
}
