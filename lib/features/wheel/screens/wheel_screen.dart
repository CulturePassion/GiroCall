import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/app_colors.dart';
import '../../../core/app_spacing.dart';
import '../../../core/constants.dart';
import '../../../core/utils/screen_padding.dart';
import '../../../core/utils/supabase_error_message.dart';
import '../../../core/utils/wheel_contacts.dart';
import '../../../shared/models/contact.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/glass_surface.dart';
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
        ? size.width - AppSpacing.xl
        : (size.width * 0.78).clamp(280.0, 380.0);

    return AppScaffold(
      title: 'Spin the Giro',
      showBackButton: false,
      actions: [
        TouchIconButton(
          icon: Icons.settings_outlined,
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
                padding: ScreenPadding.horizontal(context).copyWith(
                  top: AppSpacing.xxs,
                ),
                child: GlassSurface(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                    vertical: AppSpacing.xxs + 4,
                  ),
                  child: Text(
                    "Who's it going to be today?",
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Expanded(
                child: Center(
                  child: SizedBox(
                    width: wheelSize,
                    height: wheelSize,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(end: wheelState.rotation),
                      duration: wheelState.isSpinning
                          ? const Duration(seconds: 3)
                          : const Duration(milliseconds: 300),
                      curve: wheelState.isSpinning
                          ? Curves.decelerate
                          : Curves.easeOut,
                      builder: (context, rotation, _) {
                        return CustomPaint(
                          painter: WheelPainter(
                            contacts: selectWheelContacts(contacts),
                            rotation: rotation,
                          ),
                          size: Size(wheelSize, wheelSize),
                        );
                      },
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
                const SizedBox(height: 96),
              Padding(
                padding: ScreenPadding.all(context).copyWith(
                  bottom: ScreenPadding.bottomNavClearance(context) - 64,
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
            padding: const EdgeInsets.all(AppSpacing.sm),
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
      child: GlassSurface(
        padding: const EdgeInsets.all(AppSpacing.xs),
        borderRadius: AppSpacing.radiusLg,
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.paletteTeal, AppColors.paletteTealLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Center(
                child: Text(
                  contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.xs - 4),
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
                backgroundColor: AppColors.paletteCoral,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: AppSpacing.xxs + 2,
                ),
                minimumSize: const Size(
                  AppSpacing.minTouchTarget,
                  AppSpacing.minTouchTarget,
                ),
              ),
              icon: const Icon(Icons.phone, size: 18),
              label: const Text('Call'),
            ),
          ],
        ),
      ),
    );
  }
}
