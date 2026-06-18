import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/screen_padding.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../providers/contact_by_id_provider.dart';
import '../widgets/contact_detail_pane.dart';

/// Full-screen contact detail (mobile / narrow layouts).
class ContactDetailScreen extends ConsumerWidget {
  final String contactId;

  const ContactDetailScreen({super.key, required this.contactId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactAsync = ref.watch(contactByIdProvider(contactId));

    return AppScaffold(
      title: contactAsync.value?.name ?? 'Contact',
      body: Padding(
        padding: ScreenPadding.contactsPane(context),
        child: ContactDetailPane(contactId: contactId),
      ),
    );
  }
}