import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';


import 'config/router.dart';
import 'config/di.dart';

void main() {
  setupDependencies();
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
