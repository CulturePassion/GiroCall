import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/design/colors.dart';
import '../../../core/design/spacing.dart';
import '../../../core/design/tokens.dart';
import '../../../shared/models/contact.dart';
import '../../../shared/widgets/premium_card.dart';
import '../models/calendar_day_event.dart';
import '../providers/contact_calendar_provider.dart';
import '../services/calendar_sync_service.dart';

/// Month calendar with past-call and recommended-call markers.
class ContactsCalendarPanel extends ConsumerStatefulWidget {
  final Contact? contact;
  final ValueChanged<Contact>? onContactSelected;

  const ContactsCalendarPanel({
    super.key,
    this.contact,
    this.onContactSelected,
  });

  @override
  ConsumerState<ContactsCalendarPanel> createState() =>
      _ContactsCalendarPanelState();
}

class _ContactsCalendarPanelState extends ConsumerState<ContactsCalendarPanel> {
  late DateTime _visibleMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _visibleMonth = DateTime(now.year, now.month);
  }

  @override
  Widget build(BuildContext context) {
    final monthKey = DateTime(_visibleMonth.year, _visibleMonth.month);
    final events = widget.contact != null
        ? ref.watch(
            contactCalendarForContactProvider(
              (widget.contact!.id!, monthKey),
            ),
          )
        : ref.watch(contactCalendarMonthProvider(monthKey));

    final upcoming = ref.watch(upcomingCallRecommendationsProvider);
    final sync = ref.watch(calendarSyncServiceProvider);

    return PremiumCard(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_month_rounded, color: AppColors.main),
              const SizedBox(width: AppSpacing.xxs),
              Expanded(
                child: Text(
                  'Call calendar',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              IconButton(
                tooltip: 'Previous month',
                icon: const Icon(Icons.chevron_left),
                onPressed: () => setState(() {
                  _visibleMonth = DateTime(
                    _visibleMonth.year,
                    _visibleMonth.month - 1,
                  );
                }),
              ),
              Text(
                DateFormat.yMMMM().format(_visibleMonth),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              IconButton(
                tooltip: 'Next month',
                icon: const Icon(Icons.chevron_right),
                onPressed: () => setState(() {
                  _visibleMonth = DateTime(
                    _visibleMonth.year,
                    _visibleMonth.month + 1,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          _MonthGrid(
            month: _visibleMonth,
            events: events,
            onDayTap: (day, dayEvents) {
              if (dayEvents.isNotEmpty && widget.onContactSelected != null) {
                widget.onContactSelected!(dayEvents.first.contact);
              }
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          _LegendRow(),
          if (upcoming.isNotEmpty) ...[
            const Divider(height: AppSpacing.md),
            Text(
              'Upcoming recommendations',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.main,
                  ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            ...upcoming.take(4).map(
                  (c) => _UpcomingRow(
                    contact: c,
                    onTap: widget.onContactSelected == null
                        ? null
                        : () => widget.onContactSelected!(c),
                  ),
                ),
          ],
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: () async {
              final list =
                  widget.contact != null ? [widget.contact!] : upcoming;
              if (list.isEmpty) return;
              final ok = await sync.syncRecommendations(list);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    ok
                        ? 'Added to your calendar. Syncs with device calendars (Outlook, Google, iCloud).'
                        : 'Could not add to calendar.',
                  ),
                ),
              );
            },
            icon: const Icon(Icons.sync_rounded, size: 18),
            label: Text(
              widget.contact != null
                  ? 'Sync call to calendar'
                  : 'Sync recommendations to calendar',
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthGrid extends StatelessWidget {
  final DateTime month;
  final List<CalendarDayEvent> events;
  final void Function(DateTime day, List<CalendarDayEvent> events)? onDayTap;

  const _MonthGrid({
    required this.month,
    required this.events,
    this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    final first = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final startWeekday = first.weekday % 7;
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    final weekdays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    return Column(
      children: [
        Row(
          children: weekdays
              .map(
                (d) => Expanded(
                  child: Center(
                    child: Text(
                      d,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: AppSpacing.xxs),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            childAspectRatio: 1.1,
          ),
          itemCount: startWeekday + daysInMonth,
          itemBuilder: (context, index) {
            if (index < startWeekday) return const SizedBox.shrink();

            final day = index - startWeekday + 1;
            final date = DateTime(month.year, month.month, day);
            final dayEvents = events
                .where(
                  (e) =>
                      e.date.year == date.year &&
                      e.date.month == date.month &&
                      e.date.day == date.day,
                )
                .toList();
            final hasPast = dayEvents.any((e) => e.isPastCall);
            final hasFuture = dayEvents.any((e) => e.isRecommended);
            final isToday = date == todayDate;

            return Material(
              color: isToday ? AppColors.softTeal : Colors.transparent,
              borderRadius: BorderRadius.circular(AppTokens.radiusSm),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                onTap: dayEvents.isEmpty
                    ? null
                    : () => onDayTap?.call(date, dayEvents),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$day',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight:
                                isToday ? FontWeight.w800 : FontWeight.w500,
                          ),
                    ),
                    if (hasPast || hasFuture)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (hasPast)
                            const Icon(
                              Icons.phone_callback_rounded,
                              size: 10,
                              color: AppColors.main,
                            ),
                          if (hasPast && hasFuture) const SizedBox(width: 2),
                          if (hasFuture)
                            const Icon(
                              Icons.phone_forwarded_rounded,
                              size: 10,
                              color: AppColors.orange,
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _LegendRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.phone_callback_rounded,
            size: 14, color: AppColors.main),
        const SizedBox(width: 4),
        Text('Past call', style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(width: AppSpacing.sm),
        const Icon(Icons.phone_forwarded_rounded,
            size: 14, color: AppColors.orange),
        const SizedBox(width: 4),
        Text('Recommended', style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}

class _UpcomingRow extends StatelessWidget {
  final Contact contact;
  final VoidCallback? onTap;

  const _UpcomingRow({required this.contact, this.onTap});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat.MMMd();
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 16,
        backgroundColor: AppColors.softOrange,
        child: Text(
          contact.initials,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
        ),
      ),
      title: Text(contact.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text('Suggested ${fmt.format(contact.nextRecommendedCallAt)}'),
      trailing: const Icon(Icons.phone_forwarded_rounded,
          size: 18, color: AppColors.orange),
      onTap: onTap,
    );
  }
}
