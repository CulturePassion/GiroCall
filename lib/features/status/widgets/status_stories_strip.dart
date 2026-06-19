import 'package:flutter/material.dart';

import '../../../core/design/spacing.dart';
import '../../../shared/models/user_status_story.dart';
import 'status_avatar.dart';

/// Compact horizontal strip of friends with active status (story-style).
class StatusStoriesStrip extends StatelessWidget {
  final List<ContactStatusUpdate> updates;
  final ValueChanged<ContactStatusUpdate> onTap;

  const StatusStoriesStrip({
    super.key,
    required this.updates,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (updates.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 108,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
        itemCount: updates.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final update = updates[index];
          return _StoryBubble(
            update: update,
            onTap: () => onTap(update),
          );
        },
      ),
    );
  }
}

class _StoryBubble extends StatelessWidget {
  final ContactStatusUpdate update;
  final VoidCallback onTap;

  const _StoryBubble({
    required this.update,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final firstName = update.contactName.split(' ').first;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        child: SizedBox(
          width: 72,
          child: Column(
            children: [
              StatusAvatar(
                initials: update.contactName.isNotEmpty
                    ? update.contactName[0].toUpperCase()
                    : '?',
                statusType: update.statusType,
                imageUrl: update.avatarUrl,
                radius: 26,
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                firstName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                update.statusType.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: update.statusType.color,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
