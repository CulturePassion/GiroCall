import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../core/utils/weighting_utils.dart';
import '../../../core/utils/wheel_contacts.dart';
import '../../../shared/models/contact.dart';
import '../../contacts/providers/contacts_notifier.dart';

/// State of the spinning wheel.
class WheelState {
  final bool isSpinning;
  final int? selectedIndex;
  final double rotation;
  final Contact? selectedContact;

  const WheelState({
    this.isSpinning = false,
    this.selectedIndex,
    this.rotation = 0,
    this.selectedContact,
  });

  WheelState copyWith({
    bool? isSpinning,
    int? selectedIndex,
    double? rotation,
    Contact? selectedContact,
  }) {
    return WheelState(
      isSpinning: isSpinning ?? this.isSpinning,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      rotation: rotation ?? this.rotation,
      selectedContact: selectedContact ?? this.selectedContact,
    );
  }
}

/// Manages wheel spin animation state and weighted selection.
class WheelNotifier extends StateNotifier<WheelState> {
  final Ref _ref;

  WheelNotifier(this._ref) : super(const WheelState());

  List<Contact> get _contacts {
    final all = _ref.read(contactsNotifierProvider).value ?? [];
    return selectWheelContacts(all);
  }

  bool get canSpin => _contacts.length >= 2 && !state.isSpinning;

  /// Spins the wheel and returns the selected contact.
  Future<Contact?> spin() async {
    final contacts = _contacts;
    if (contacts.length < 2 || state.isSpinning) return null;

    state = state.copyWith(isSpinning: true, selectedContact: null);

    final weights = computeWheelWeights(contacts);
    final selectedIndex = selectWeightedIndex(weights);

    // Each slice is 360 / contacts.length degrees. We land the selected
    // slice under the top arrow (270 degrees) plus several full rotations.
    final sliceAngle = 360 / contacts.length;
    final targetSliceCenter = selectedIndex * sliceAngle + sliceAngle / 2;
    final currentVisualAngle = (state.rotation + targetSliceCenter) % 360;
    const arrowAngle = 270.0;
    final deltaToTop = (arrowAngle - currentVisualAngle + 360) % 360;
    final fullRotations = 5 + Random().nextInt(4);
    final targetRotation = state.rotation + fullRotations * 360 + deltaToTop;

    state = state.copyWith(
      rotation: targetRotation,
      selectedIndex: selectedIndex,
    );

    // Wait for the animation duration.
    await Future.delayed(const Duration(seconds: 3));

    final selected = contacts[selectedIndex];
    state = state.copyWith(
      isSpinning: false,
      selectedContact: selected,
    );

    return selected;
  }

  void reset() {
    state = const WheelState();
  }
}

final wheelProvider = StateNotifierProvider<WheelNotifier, WheelState>((ref) {
  return WheelNotifier(ref);
});
