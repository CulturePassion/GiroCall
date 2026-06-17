import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_colors.dart';
import '../../../core/app_spacing.dart';
import '../../../core/extensions/date_time_extensions.dart';
import '../../../shared/models/contact.dart';
import '../../../shared/widgets/glass_surface.dart';
import '../../status/providers/contact_status_map_provider.dart';
import '../../status/widgets/status_avatar.dart';

class ContactListTile extends ConsumerWidget {
  final Contact contact;
  final VoidCallback? onTap;
  final VoidCallback? onCall;

  const ContactListTile({
    super.key,
    required this.contact,
    this.onTap,
    this.onCall,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusType = ref.watch(contactStatusMapProvider)[contact.id];
    final daysSince = contact.daysSinceLastCall;
    final statusText = daysSince == null
        ? 'Never called'
        : 'Last called ${contact.lastCalledAt!.toRelativeDateString()}';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
      child: GlassSurface(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs - 4,
          vertical: AppSpacing.xxs + 2,
        ),
        onTap: onTap,
        child: Row(
          children: [
            StatusAvatar(
              initials: contact.initials,
              statusType: statusType,
              imageUrl: contact.photoUrl,
              radius: 24,
            ),
            const SizedBox(width: AppSpacing.xs - 4),
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
                              ?.copyWith(fontSize: 15),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
                            color: contact.tag!.color.withValues(alpha: 0.15),
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusSm),
                            border: Border.all(
                              color: contact.tag!.color.withValues(alpha: 0.3),
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
                          color:
                              contact.isOverdue ? AppColors.paletteCoral : null,
                          fontWeight:
                              contact.isOverdue ? FontWeight.w600 : null,
                        ),
                  ),
                ],
              ),
            ),
            if (onCall != null)
              Material(
                color: AppColors.paletteTeal.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                child: InkWell(
                  onTap: onCall,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  child: const SizedBox(
                    width: AppSpacing.minTouchTarget,
                    height: AppSpacing.minTouchTarget,
                    child: Icon(
                      Icons.phone,
                      color: AppColors.paletteTeal,
                      size: 22,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
