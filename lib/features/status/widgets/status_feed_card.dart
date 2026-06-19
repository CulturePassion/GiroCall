import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/design/colors.dart';
import '../../../core/design/spacing.dart';
import '../../../core/design/tokens.dart';
import '../../../shared/models/user_status_story.dart';
import '../../../shared/widgets/premium_card.dart';
import 'status_avatar.dart';

class StatusFeedCard extends StatelessWidget {
  final ContactStatusUpdate update;
  final VoidCallback onTap;

  const StatusFeedCard({
    super.key,
    required this.update,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat.jm();
    final color = update.statusType.color;
    final isDark = AppColors.isDark(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: PremiumCard(
        accentColor: color,
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppTokens.radiusLg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StatusAvatar(
                  initials: update.contactName.isNotEmpty
                      ? update.contactName[0].toUpperCase()
                      : '?',
                  statusType: update.statusType,
                  imageUrl: update.avatarUrl,
                  radius: 22,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              update.contactName,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            timeFormat.format(update.updatedAt.toLocal()),
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: AppColors.textMuted(context),
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xxs,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: isDark ? 0.22 : 0.12),
                          borderRadius:
                              BorderRadius.circular(AppTokens.radiusSm),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(update.statusType.icon,
                                size: 14, color: color),
                            const SizedBox(width: 4),
                            Text(
                              update.statusType.label,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: color,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        update.message,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              height: 1.45,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.xxs),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.textMuted(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
