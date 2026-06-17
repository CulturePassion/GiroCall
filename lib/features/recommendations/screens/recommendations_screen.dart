import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/screen_padding.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../contacts/widgets/contact_list_tile.dart';
import '../providers/recommendations_provider.dart';

class RecommendationsScreen extends ConsumerWidget {
  const RecommendationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recommendations = ref.watch(recommendationsProvider);

    return AppScaffold(
      title: 'Call Again',
      showBackButton: false,
      body: recommendations.isEmpty
          ? const EmptyState(
              icon: Icons.check_circle_outline,
              title: 'All caught up!',
              message:
                  'No one is overdue right now. Great job staying connected.',
            )
          : ListView.builder(
              padding: ScreenPadding.all(context).copyWith(
                bottom: ScreenPadding.bottomNavClearance(context),
              ),
              itemCount: recommendations.length,
              itemBuilder: (context, index) {
                final contact = recommendations[index];
                return ContactListTile(
                  contact: contact,
                  onTap: () => context.push('/contacts/${contact.id}'),
                  onCall: () => context.push('/call/${contact.id}'),
                );
              },
            ),
    );
  }
}
