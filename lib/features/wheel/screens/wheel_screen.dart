import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/app_colors.dart';
import '../../../core/constants.dart';
import '../../../core/utils/screen_padding.dart';
import '../../../core/utils/supabase_error_message.dart';
import '../../../core/utils/wheel_contacts.dart';
import '../../../shared/models/contact.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../contacts/providers/contacts_notifier.dart';
import '../providers/wheel_provider.dart';
import '../widgets/wheel_painter.dart';

class WheelScreen extends ConsumerWidget {
  const WheelScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactsAsync = ref.watch(contactsNotifierProvider);
    final wheelState = ref.watch(wheelProvider);
    final wheelNotifier = ref.read(wheelProvider.notifier);
    final size = MediaQuery.sizeOf(context);
    final wheelSize = size.width < 400
        ? size.width - 48
        : (size.width * 0.75).clamp(280.0, 360.0);

    return AppScaffold(
      title: 'Spin the Giro',
      showBackButton: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          tooltip: 'Settings',
          onPressed: () => context.push('/settings'),
        ),
      ],
      body: contactsAsync.when(
        data: (contacts) {
          if (contacts.length < Constants.minWheelSlices) {
            return EmptyState(
              icon: Icons.group_add_outlined,
              title: 'Add a few people first',
              message:
                  'You need at least ${Constants.minWheelSlices} contacts to spin the Giro.',
              actionLabel: 'Add contacts',
              onAction: () => context.push('/contacts'),
            );
          }

          return Column(
            children: [
              Padding(
                padding: ScreenPadding.horizontal(context).copyWith(top: 8),
                child: Text(
                  "Who's it going to be today?",
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Center(
                  child: SizedBox(
                    width: wheelSize,
                    height: wheelSize,
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(end: wheelState.rotation),
                          duration: wheelState.isSpinning
                              ? const Duration(seconds: 3)
                              : const Duration(milliseconds: 300),
                          curve: wheelState.isSpinning
                              ? Curves.decelerate
                              : Curves.easeOut,
                          builder: (context, rotation, child) {
                            return CustomPaint(
                              painter: WheelPainter(
                                contacts: selectWheelContacts(contacts),
                                rotation: rotation,
                              ),
                              size: Size(wheelSize, wheelSize),
                            );
                          },
                        ),
                        Positioned(
                          top: -4,
                          child: Icon(
                            Icons.arrow_drop_down,
                            size: 44,
                            color: AppColors.accentCoral,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (wheelState.selectedContact != null)
                _SelectedContactCard(
                  contact: wheelState.selectedContact!,
                  onCall: () =>
                      context.push('/call/${wheelState.selectedContact!.id}'),
                )
              else
                const SizedBox(height: 100),
              Padding(
                padding: ScreenPadding.all(context).copyWith(
                  bottom: ScreenPadding.bottomNavClearance(context) - 56,
                ),
                child: PrimaryButton(
                  label:
                      wheelState.isSpinning ? 'Spinning...' : 'Spin the Giro',
                  icon: Icons.rotate_right,
                  onPressed:
                      wheelNotifier.canSpin ? () => wheelNotifier.spin() : null,
                  isLoading: wheelState.isSpinning,
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(supabaseErrorMessage(error)),
          ),
        ),
      ),
    );
  }
}

class _SelectedContactCard extends StatelessWidget {
  final Contact contact;
  final VoidCallback onCall;

  const _SelectedContactCard({required this.contact, required this.onCall});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: ScreenPadding.horizontal(context),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primaryTeal,
                child: Text(
                  contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      contact.phone,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: onCall,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryTeal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
                icon: const Icon(Icons.phone, size: 18),
                label: const Text('Call'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
