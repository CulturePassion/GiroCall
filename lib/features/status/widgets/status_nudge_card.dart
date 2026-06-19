import 'package:flutter/material.dart';

import '../../../core/design/colors.dart';
import '../../../core/design/spacing.dart';
import '../../../core/design/tokens.dart';
import '../../../shared/models/contact.dart';
import '../../../shared/widgets/premium_card.dart';
import 'status_avatar.dart';

class StatusNudgeCard extends StatelessWidget {
  final Contact contact;
  final VoidCallback onTap;
  final VoidCallback onCall;

  const StatusNudgeCard({
    super.key,
    required this.contact,
    required this.onTap,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    final days = contact.daysSinceLastCall;
    final subtitle = days == null
        ? 'Never called — they\'d love to hear from you'
        : '$days days since your last call';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: PremiumCard(
        accentColor: AppColors.orange,
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppTokens.radiusLg),
            child: Row(
              children: [
                StatusAvatar(initials: contact.initials, radius: 22),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contact.name,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.orange,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
                Material(
                  color: AppColors.softTeal,
                  borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                  child: InkWell(
                    onTap: onCall,
                    borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                    child: const SizedBox(
                      width: AppTokens.minTouchTarget,
                      height: AppTokens.minTouchTarget,
                      child: Icon(
                        Icons.phone_rounded,
                        color: AppColors.main,
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
