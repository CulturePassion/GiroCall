import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants.dart';
import '../../../core/design/colors.dart';
import '../../../core/design/microcopy.dart';
import '../../../core/design/spacing.dart';
import '../../../core/design/tokens.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/utils/screen_padding.dart';
import '../../../core/utils/wheel_contacts.dart';
import '../../../shared/models/contact.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/premium_card.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/stats_widgets.dart';
import '../../contacts/providers/contacts_notifier.dart';
import '../../notifications/providers/settings_repository_provider.dart';
import '../../stats/providers/stats_provider.dart';
import '../../status/widgets/status_avatar.dart';
import '../providers/wheel_provider.dart';
import '../widgets/giro_hub.dart';
import '../widgets/wheel_painter.dart';

const _kWheelActionMaxWidth = 280.0;
const _kWheelResultMaxWidth = 340.0;

class WheelScreen extends ConsumerWidget {
  const WheelScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactsAsync = ref.watch(contactsNotifierProvider);
    final wheelState = ref.watch(wheelProvider);
    final wheelNotifier = ref.read(wheelProvider.notifier);

    return AppScaffold(
      variant: AppScaffoldVariant.hero,
      title: 'Spin the Giro',
      showBackButton: false,
      actions: [
        if (!ResponsiveLayout.isDesktop(context))
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => context.push('/settings'),
            color: Colors.white,
            constraints: const BoxConstraints(
              minWidth: AppTokens.minTouchTarget,
              minHeight: AppTokens.minTouchTarget,
            ),
          ),
      ],
      body: contactsAsync.when(
        data: (contacts) {
          if (contacts.length < Constants.minWheelSlices) {
            return Padding(
              padding: ScreenPadding.scrollBottom(context),
              child: EmptyState(
                icon: Icons.favorite_outline,
                title: Microcopy.wheelEmptyTitle,
                message: Microcopy.wheelEmptyMessage(Constants.minWheelSlices),
                actionLabel: 'Add contacts',
                onAction: () => context.go('/contacts'),
              ),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final padding = ScreenPadding.horizontal(context).copyWith(
                bottom: ScreenPadding.bottomNavClearance(context),
                top: AppSpacing.xs,
              );
              final isDesktop = ResponsiveLayout.isDesktop(context);
              final isTablet = ResponsiveLayout.isTablet(context);

              Widget layout;
              if (isDesktop) {
                layout = _DashboardWheelLayout(
                  contacts: contacts,
                  wheelState: wheelState,
                  wheelNotifier: wheelNotifier,
                  maxHeight: constraints.maxHeight,
                  stats: ref.watch(statsProvider),
                  dailyGoal:
                      ref.watch(userSettingsProvider).value?.dailyCallGoal ??
                          Constants.defaultDailyCallGoal,
                );
              } else if (isTablet) {
                layout = _WideWheelLayout(
                  contacts: contacts,
                  wheelState: wheelState,
                  wheelNotifier: wheelNotifier,
                  maxHeight: constraints.maxHeight,
                );
              } else {
                layout = _NarrowWheelLayout(
                  contacts: contacts,
                  wheelState: wheelState,
                  wheelNotifier: wheelNotifier,
                  maxHeight: constraints.maxHeight,
                  maxWidth: constraints.maxWidth,
                );
              }

              return Padding(padding: padding, child: layout);
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
        error: (error, _) => ErrorState(
          error: error,
          title: Microcopy.errorLoadWheel,
          onRetry: () => ref.invalidate(contactsNotifierProvider),
        ),
      ),
    );
  }
}

class _DashboardWheelLayout extends StatelessWidget {
  final List<Contact> contacts;
  final WheelState wheelState;
  final WheelNotifier wheelNotifier;
  final double maxHeight;
  final UserStats stats;
  final int dailyGoal;

  const _DashboardWheelLayout({
    required this.contacts,
    required this.wheelState,
    required this.wheelNotifier,
    required this.maxHeight,
    required this.stats,
    required this.dailyGoal,
  });

  @override
  Widget build(BuildContext context) {
    final wheelSize =
        _computeWheelSize(maxWidth: 460, maxHeight: maxHeight - AppSpacing.xl);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 3,
          child: _WheelColumn(
            contacts: contacts,
            wheelState: wheelState,
            wheelNotifier: wheelNotifier,
            wheelSize: wheelSize,
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (wheelState.selectedContact != null)
                  _WheelResult(
                    contact: wheelState.selectedContact,
                    onCall: () => context.push(
                      '/call/${wheelState.selectedContact!.id}',
                    ),
                  )
                else
                  StatsDashboardPanel(stats: stats, dailyGoal: dailyGoal),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _WideWheelLayout extends StatelessWidget {
  final List<Contact> contacts;
  final WheelState wheelState;
  final WheelNotifier wheelNotifier;
  final double maxHeight;

  const _WideWheelLayout({
    required this.contacts,
    required this.wheelState,
    required this.wheelNotifier,
    required this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    final wheelSize =
        _computeWheelSize(maxWidth: 420, maxHeight: maxHeight - AppSpacing.lg);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 3,
          child: _WheelColumn(
            contacts: contacts,
            wheelState: wheelState,
            wheelNotifier: wheelNotifier,
            wheelSize: wheelSize,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          flex: 2,
          child: Align(
            alignment: Alignment.center,
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(maxWidth: _kWheelResultMaxWidth),
              child: _WheelResult(
                contact: wheelState.selectedContact,
                onCall: wheelState.selectedContact == null
                    ? null
                    : () => context.push(
                          '/call/${wheelState.selectedContact!.id}',
                        ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NarrowWheelLayout extends StatelessWidget {
  final List<Contact> contacts;
  final WheelState wheelState;
  final WheelNotifier wheelNotifier;
  final double maxHeight;
  final double maxWidth;

  const _NarrowWheelLayout({
    required this.contacts,
    required this.wheelState,
    required this.wheelNotifier,
    required this.maxHeight,
    required this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    final hasResult = wheelState.selectedContact != null;
    final spinningExtra = wheelState.isSpinning ? AppSpacing.lg + 24.0 : 0.0;
    const headlineReserve = 52.0;
    const spinButtonReserve = 56.0;
    const resultReserve = 248.0;
    final fixedReserve = headlineReserve +
        spinButtonReserve +
        AppSpacing.md +
        (hasResult ? resultReserve : 0) +
        spinningExtra;
    final wheelSize = _computeWheelSize(
      maxWidth: maxWidth - AppSpacing.xl,
      maxHeight: math.max(120.0, maxHeight - fixedReserve),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: AppSpacing.xs),
                _WheelHeadline(selected: hasResult),
                const SizedBox(height: AppSpacing.sm),
                _WheelDisc(
                  contacts: contacts,
                  wheelState: wheelState,
                  size: wheelSize,
                ),
                if (wheelState.isSpinning) ...[
                  const SizedBox(height: AppSpacing.sm),
                  const _SpinningLabel(),
                ],
                if (hasResult) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: _kWheelResultMaxWidth,
                      ),
                      child: _WheelResult(
                        contact: wheelState.selectedContact,
                        onCall: () => context.push(
                          '/call/${wheelState.selectedContact!.id}',
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.sm),
                _SpinButton(
                  wheelState: wheelState,
                  onSpin: wheelNotifier.canSpin ? wheelNotifier.spin : null,
                ),
                const SizedBox(height: AppSpacing.xxs),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _WheelColumn extends StatelessWidget {
  final List<Contact> contacts;
  final WheelState wheelState;
  final WheelNotifier wheelNotifier;
  final double wheelSize;

  const _WheelColumn({
    required this.contacts,
    required this.wheelState,
    required this.wheelNotifier,
    required this.wheelSize,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _WheelHeadline(selected: wheelState.selectedContact != null),
        const SizedBox(height: AppSpacing.md),
        _WheelDisc(
          contacts: contacts,
          wheelState: wheelState,
          size: wheelSize,
        ),
        if (wheelState.isSpinning) ...[
          const SizedBox(height: AppSpacing.sm),
          const _SpinningLabel(),
        ],
        const SizedBox(height: AppSpacing.lg),
        _SpinButton(
          wheelState: wheelState,
          onSpin: wheelNotifier.canSpin ? wheelNotifier.spin : null,
        ),
      ],
    );
  }
}

class _WheelHeadline extends StatelessWidget {
  final bool selected;

  const _WheelHeadline({required this.selected});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppTokens.animationNormal,
      child: Text(
        key: ValueKey(selected),
        selected ? Microcopy.wheelSelected : Microcopy.wheelReady,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: Colors.white,
          height: 1.35,
          shadows: const [Shadow(color: Colors.black26, blurRadius: 8)],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _SpinningLabel extends StatelessWidget {
  const _SpinningLabel();

  @override
  Widget build(BuildContext context) {
    return Text(
      Microcopy.wheelSpinning,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white.withValues(alpha: 0.9),
            fontStyle: FontStyle.italic,
          ),
    );
  }
}

class _WheelDisc extends StatelessWidget {
  final List<Contact> contacts;
  final WheelState wheelState;
  final double size;

  const _WheelDisc({
    required this.contacts,
    required this.wheelState,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: size + AppSpacing.md,
        height: size + AppSpacing.md,
        padding: const EdgeInsets.all(AppSpacing.xxs),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 28,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween<double>(end: wheelState.rotation),
                duration: wheelState.isSpinning
                    ? AppTokens.wheelSpin
                    : AppTokens.animationSlow,
                curve: wheelState.isSpinning
                    ? Curves.elasticOut
                    : Curves.fastOutSlowIn,
                builder: (context, rotation, _) {
                  return CustomPaint(
                    painter: WheelPainter(
                      contacts: selectWheelContacts(contacts),
                      rotation: rotation,
                    ),
                    size: Size(size, size),
                  );
                },
              ),
              GiroHub(
                isSpinning: wheelState.isSpinning,
                size: size * 0.36,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpinButton extends StatelessWidget {
  final WheelState wheelState;
  final VoidCallback? onSpin;

  const _SpinButton({required this.wheelState, this.onSpin});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _kWheelActionMaxWidth),
        child: PrimaryButton(
          label: wheelState.isSpinning
              ? Microcopy.wheelSpinning
              : Microcopy.wheelSpinCta,
          icon: Icons.rotate_right,
          onPressed: onSpin,
          isLoading: wheelState.isSpinning,
          fullWidth: true,
        ),
      ),
    );
  }
}

class _WheelResult extends StatelessWidget {
  final Contact? contact;
  final VoidCallback? onCall;

  const _WheelResult({required this.contact, this.onCall});

  @override
  Widget build(BuildContext context) {
    if (contact == null) {
      return PremiumCard(
        accentColor: AppColors.main,
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_awesome,
              size: 40,
              color: AppColors.main.withValues(alpha: 0.8),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Who will it be?',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              'Spin the Giro and your match will appear here.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return PremiumCard(
      accentColor: AppColors.orange,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Your pick',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.orange,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          StatusAvatar(
            initials: contact!.initials,
            imageUrl: contact!.photoUrl,
            radius: 40,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            contact!.name,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            contact!.phone,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onCall,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.orange,
                foregroundColor: Colors.white,
                minimumSize: const Size(0, AppTokens.minTouchTarget),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTokens.radiusLg),
                ),
              ),
              icon: const Icon(Icons.phone),
              label: const Text('Call now'),
            ),
          ),
        ],
      ),
    );
  }
}

double _computeWheelSize({
  required double maxWidth,
  required double maxHeight,
}) {
  if (maxWidth <= 0 || maxHeight <= 0) return 120;

  var size = maxWidth < 400
      ? maxWidth - AppSpacing.md
      : (maxWidth * 0.85).clamp(240.0, 380.0);

  size = math.min(size, maxHeight);
  return size.clamp(120.0, 380.0);
}
