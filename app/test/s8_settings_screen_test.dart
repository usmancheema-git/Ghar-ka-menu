import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ghar_ka_menu/core/theme/app_theme.dart';
import 'package:ghar_ka_menu/data/mock/mock_household_store.dart';
import 'package:ghar_ka_menu/presentation/screens/s8_settings/s8_settings_screen.dart';

Widget _app() {
  final router = GoRouter(
    initialLocation: '/settings',
    routes: [
      GoRoute(path: '/settings', builder: (_, _) => const S8SettingsScreen()),
      GoRoute(path: '/home', builder: (_, _) => const _Stub('S2')),
      GoRoute(path: '/dishes', builder: (_, _) => const _Stub('S5')),
      GoRoute(path: '/history', builder: (_, _) => const _Stub('S7')),
    ],
  );

  return MaterialApp.router(theme: AppTheme.lightTheme, routerConfig: router);
}

class _Stub extends StatelessWidget {
  const _Stub(this.label);

  final String label;

  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: Text(label)));
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('settings screen shows household info, alert time and members', (
    tester,
  ) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(find.text('Manage household parameters'), findsOneWidget);
    expect(find.text('Awais Family'), findsOneWidget);
    expect(find.text('482910'), findsOneWidget);
    expect(find.text('Next-Day Alert Time'), findsOneWidget);
    expect(find.text('Planner'), findsWidgets);
    expect(find.text('Family Members (6)'), findsOneWidget);
    expect(find.text('Awais (You)'), findsOneWidget);
  });

  testWidgets('role toggle switches from planner to member', (tester) async {
    MockHouseholdStore.userRole = 'planner';
    addTearDown(() => MockHouseholdStore.userRole = 'planner');

    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(find.text('Planner'), findsWidgets);
    expect(find.text('Member'), findsWidgets);

    await tester.tap(find.byKey(const ValueKey('role-member-chip')));
    await tester.pumpAndSettle();

    expect(MockHouseholdStore.userRole, 'member');
    expect(find.text('Member'), findsWidgets);
    expect(find.text('Awais (You)'), findsOneWidget);
    expect(find.byKey(const ValueKey('role-member-chip')), findsOneWidget);
  });

  testWidgets(
    'bottom navigation remains on settings tab while on settings screen',
    (tester) async {
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsNWidgets(2));
      expect(find.text('History'), findsOneWidget);
    },
  );
}
