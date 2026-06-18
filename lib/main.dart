import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/bootstrap.dart';
import 'core/constants.dart';
import 'core/design/theme.dart';
import 'core/supabase_config.dart';
import 'core/supabase_provider.dart';
import 'core/theme/theme_mode_provider.dart';
import 'router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const supabaseUrl = String.fromEnvironment(Constants.supabaseUrlKey);
  const supabaseAnonKey = String.fromEnvironment(Constants.supabaseAnonKey);
  final config = SupabaseConfig.fromEnvironment(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  await initializeSupabase(
    url: config.url,
    anonKey: config.anonKey,
  );

  runApp(
    ProviderScope(
      overrides: [
        supabaseConfigProvider.overrideWithValue(config),
      ],
      child: const GiroCallApp(),
    ),
  );
}

class GiroCallApp extends ConsumerStatefulWidget {
  const GiroCallApp({super.key});

  @override
  ConsumerState<GiroCallApp> createState() => _GiroCallAppState();
}

class _GiroCallAppState extends ConsumerState<GiroCallApp> {
  @override
  void initState() {
    super.initState();
    ref.listenManual(authUserProvider, (previous, next) {
      final authState = next.value;
      if (authState?.event == AuthChangeEvent.passwordRecovery) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(routerProvider).go('/settings/account/password');
        });
      }
      if (authState?.session != null && previous?.value?.session == null) {
        onUserSignedIn(ref);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      bootstrapApp(ref);
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: Constants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
