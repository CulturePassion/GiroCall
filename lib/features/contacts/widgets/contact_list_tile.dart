import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_colors.dart';
import '../../../core/extensions/date_time_extensions.dart';
import '../../../shared/models/contact.dart';
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

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              StatusAvatar(
                initials: contact.initials,
                statusType: statusType,
                imageUrl: contact.photoUrl,
                radius: 22,
              ),
              const SizedBox(width: 12),
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
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: contact.tag!.color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              contact.tag!.label,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: contact.tag!.color,
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
                                ? AppColors.accentCoral
                                : null,
                            fontWeight:
                                contact.isOverdue ? FontWeight.w600 : null,
                          ),
                    ),
                  ],
                ),
              ),
              if (onCall != null)
                Material(
                  color: AppColors.primaryTeal.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: onCall,
                    borderRadius: BorderRadius.circular(12),
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Icon(
                        Icons.phone,
                        color: AppColors.primaryTeal,
                        size: 22,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
