import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/colors.dart';
import '../../../core/design/spacing.dart';
import '../../../core/design/tokens.dart';
import '../../../core/extensions/date_time_extensions.dart';
import '../../../shared/models/contact.dart';
import '../../status/providers/contact_status_map_provider.dart';
import '../../status/widgets/status_avatar.dart';
import '../providers/contacts_notifier.dart';

class ContactListTile extends ConsumerWidget {
  final Contact contact;
  final VoidCallback? onTap;
  final VoidCallback? onCall;
  final bool selected;

  const ContactListTile({
    super.key,
    required this.contact,
    this.onTap,
    this.onCall,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusType = ref.watch(contactStatusMapProvider)[contact.id];
    final daysSince = contact.daysSinceLastCall;
    final statusText = daysSince == null
        ? 'Never called — maybe today?'
        : 'Last called ${contact.lastCalledAt!.toRelativeDateString()}';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
      child: Material(
        color: AppColors.cardSurface(context),
        elevation: selected ? 2 : 0,
        shadowColor: AppColors.vibrantGreen.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          side: BorderSide(
            color: selected
                ? AppColors.vibrantGreen
                : (AppColors.isDark(context)
                    ? AppColors.darkDivider
                    : AppColors.grey200),
            width: selected ? 2 : 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: AppSpacing.xxs + 2,
            ),
            child: Row(
              children: [
                StatusAvatar(
                  initials: contact.initials,
                  statusType: statusType,
                  imageUrl: contact.photoUrl,
                  radius: 24,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              contact.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (contact.isFavorite)
                            const Padding(
                              padding: EdgeInsets.only(left: 4),
                              child: Icon(
                                Icons.favorite,
                                size: 14,
                                color: AppColors.brightOrange,
                              ),
                            ),
                          if (contact.tag != null) ...[
                            const SizedBox(width: AppSpacing.xxs),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xxs,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.softGreen,
                                borderRadius: BorderRadius.circular(
                                  AppTokens.radiusSm,
                                ),
                                border: Border.all(
                                  color: contact.tag!.color,
                                ),
                              ),
                              child: Text(
                                contact.tag!.label,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: contact.tag!.color,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        contact.phone,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        statusText,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: contact.isOverdue
                                  ? AppColors.brightOrange
                                  : AppColors.textSecondary,
                              fontWeight:
                                  contact.isOverdue ? FontWeight.w600 : null,
                            ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: contact.isFavorite
                      ? 'Remove from favorites'
                      : 'Add to favorites',
                  icon: Icon(
                    contact.isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: contact.isFavorite
                        ? AppColors.brightOrange
                        : AppColors.warmGray,
                  ),
                  onPressed: () => ref
                      .read(contactsNotifierProvider.notifier)
                      .toggleFavorite(contact),
                ),
                if (onCall != null)
                  Material(
                    color: AppColors.softGreen,
                    borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                    child: InkWell(
                      onTap: onCall,
                      borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                      child: const SizedBox(
                        width: AppTokens.minTouchTarget,
                        height: AppTokens.minTouchTarget,
                        child: Icon(
                          Icons.phone,
                          color: AppColors.vibrantGreen,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
