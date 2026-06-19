import 'package:flutter/material.dart';

import '../../../shared/widgets/live_clock_header.dart';

/// Contacts hub clock — delegates to shared [LiveClockHeader].
class ContactsClockHeader extends StatelessWidget {
  const ContactsClockHeader({super.key});

  @override
  Widget build(BuildContext context) => const LiveClockHeader();
}
