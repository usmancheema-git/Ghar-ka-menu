import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'config/router.dart';
import 'config/di.dart';
import 'config/supabase_config.dart';
import 'data/repositories/auth_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final supabase = await SupabaseConfig.initialize();
  setupDependencies(supabase: supabase);
  await getIt<AuthRepository>().restoreSession();
  runApp(const GharKaMenuApp());
}

class GharKaMenuApp extends StatelessWidget {
  const GharKaMenuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Ghar ka Menu',
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
