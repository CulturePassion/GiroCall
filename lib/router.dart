import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/supabase_provider.dart';
import 'core/utils/platform_capabilities.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/call_log/screens/log_call_screen.dart';
import 'features/contacts/screens/add_contact_screen.dart';
import 'features/contacts/screens/edit_contact_screen.dart';
import 'features/notifications/screens/notification_settings_screen.dart';
import 'features/contacts/screens/contact_detail_screen.dart';
import 'features/contacts/screens/contact_list_screen.dart';
import 'features/contacts/screens/import_contacts_screen.dart';
import 'features/contacts/screens/scan_contact_screen.dart';
import 'features/profile/screens/my_card_screen.dart';
import 'features/profile/screens/profile_edit_screen.dart';
import 'features/profile/screens/profile_screen.dart';
import 'features/profile/screens/public_card_screen.dart';
import 'features/settings/screens/account_screen.dart';
import 'features/settings/screens/change_password_screen.dart';
import 'features/settings/screens/settings_screen.dart';
import 'features/stats/screens/stats_screen.dart';
import 'features/status/screens/status_screen.dart';
import 'features/wheel/screens/wheel_screen.dart';
import 'app/shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier(0);
  ref.listen(authUserProvider, (_, __) => refresh.value++);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refresh,
    redirect: (context, state) {
      final session = ref.read(authUserProvider).value?.session;
      final location = state.matchedLocation;
      final isAuthRoute = location == '/login';
      final isPublicCard = location.startsWith('/card/');

      if (session == null && !isAuthRoute && !isPublicCard) {
        return '/login';
      }
      if (session != null && isAuthRoute) {
        return '/';
      }
      if (location == '/recommendations') {
        return '/status';
      }
      if (!supportsDeviceContactImport && location == '/contacts/import') {
        return '/contacts/add';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/card/:slug',
        builder: (context, state) {
          final slug = state.pathParameters['slug']!;
          return PublicCardScreen(slug: slug);
        },
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const WheelScreen(),
          ),
          GoRoute(
            path: '/contacts',
            builder: (context, state) => const ContactListScreen(),
            routes: [
              GoRoute(
                path: 'import',
                builder: (context, state) => const ImportContactsScreen(),
              ),
              GoRoute(
                path: 'add',
                builder: (context, state) => const AddContactScreen(),
              ),
              GoRoute(
                path: 'scan',
                builder: (context, state) => const ScanContactScreen(),
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return ContactDetailScreen(contactId: id);
                },
                routes: [
                  GoRoute(
                    path: 'edit',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return EditContactScreen(contactId: id);
                    },
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/status',
            builder: (context, state) => const StatusScreen(),
          ),
          GoRoute(
            path: '/stats',
            builder: (context, state) => const StatsScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
            routes: [
              GoRoute(
                path: 'card',
                builder: (context, state) => const MyCardScreen(),
              ),
              GoRoute(
                path: 'edit',
                builder: (context, state) => const ProfileEditScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/call/:contactId',
        builder: (context, state) {
          final contactId = state.pathParameters['contactId']!;
          return LogCallScreen(contactId: contactId);
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
        routes: [
          GoRoute(
            path: 'notifications',
            builder: (context, state) => const NotificationSettingsScreen(),
          ),
          GoRoute(
            path: 'account',
            builder: (context, state) => const AccountScreen(),
            routes: [
              GoRoute(
                path: 'password',
                builder: (context, state) => const ChangePasswordScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
