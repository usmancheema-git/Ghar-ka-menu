import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ghar_ka_menu/core/theme/app_theme.dart';
import 'package:ghar_ka_menu/data/models/day_plan_model.dart';
import 'package:ghar_ka_menu/data/repositories/history_repository.dart';
import 'package:ghar_ka_menu/presentation/screens/s7_history/s7_history_screen.dart';

/// S7 is read-only, so these cover what the household reads on screen: row
/// contents, the two badges, the empty state and the error retry.

DateTime _today() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

class _FakeHistoryRepository implements HistoryRepository {
  bool throws = false;

  /// Non-zero when a test needs to observe the in-flight state.
  Duration delay = Duration.zero;

  List<DayPlanModel> entries = [
    DayPlanModel(
      id: 'p1',
      date: DateTime(2026, 7, 16),
      dishId: 'd1',
      dishName: 'Daal Chawal Combo',
      categoryName: 'Chawal',
      status: DayPlanStatus.cooked,
    ),
    DayPlanModel(
      id: 'p2',
      date: DateTime(2026, 7, 9),
      dishId: 'd2',
      dishName: 'Beef Nihari',
      categoryName: 'Gosht',
      status: DayPlanStatus.cancelled,
    ),
    DayPlanModel(
      id: 'p3',
      date: DateTime(2026, 7, 8),
      dishId: 'd3',
      dishName: 'Aloo Qeema',
      categoryName: 'Gosht',
      // The midnight rollover has not run for this day yet.
      status: DayPlanStatus.planned,
    ),
  ];

  @override
  Future<List<DayPlanModel>> fetchHistory({
    required String householdId,
    required DateTime from,
    required DateTime to,
  }) async {
    await Future<void>.delayed(delay);
    if (throws) throw Exception('offline');
    return entries;
  }
}

Widget _app() {
  final router = GoRouter(
    initialLocation: '/history',
    routes: [
      GoRoute(path: '/history', builder: (_, _) => const S7HistoryScreen()),
      GoRoute(path: '/home', builder: (_, _) => const _Stub('S2')),
      GoRoute(path: '/dishes', builder: (_, _) => const _Stub('S5')),
      GoRoute(path: '/settings', builder: (_, _) => const _Stub('S8')),
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
  final getIt = GetIt.instance;
  late _FakeHistoryRepository repo;

  setUpAll(() {
    // Keeps the tests off the network; the bundled fallback font is used.
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    repo = _FakeHistoryRepository();
    getIt.registerFactory<HistoryRepository>(() => repo);
  });

  tearDown(() => getIt.reset());

  testWidgets('shows the header from the prototype', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(find.text('30-Day History'), findsOneWidget);
    expect(find.text('Past lunch records'), findsOneWidget);
  });

  testWidgets('a record shows the dish, date and category', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(find.text('Daal Chawal Combo'), findsOneWidget);
    expect(find.text('16 July 2026 · Chawal'), findsOneWidget);
    expect(find.text('Beef Nihari'), findsOneWidget);
    expect(find.text('9 July 2026 · Gosht'), findsOneWidget);
  });

  testWidgets('cooked reads Served and cancelled reads Cancelled',
      (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    // Two Served: the cooked day, plus the past day the rollover has not
    // converted yet (`docs/BUSINESS_RULES.md`, Day Rollover).
    expect(find.text('Served'), findsNWidgets(2));
    expect(find.text('Cancelled'), findsOneWidget);
  });

  testWidgets('the badges use the prototype colours', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    Color badgeFill(String label) {
      final container = tester.widget<Container>(
        find.ancestor(of: find.text(label), matching: find.byType(Container)).first,
      );
      return (container.decoration! as BoxDecoration).color!;
    }

    expect(badgeFill('Served'), AppColors.secondaryLight);
    expect(badgeFill('Cancelled'), AppColors.dangerLight);
  });

  testWidgets('a fresh install shows the empty state', (tester) async {
    repo.entries = [];
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(find.text('No history yet'), findsOneWidget);
    expect(
      find.text('Served and cancelled lunches will show up here.'),
      findsOneWidget,
    );
    expect(find.text('Served'), findsNothing);
  });

  testWidgets('a loading spinner shows before the records arrive',
      (tester) async {
    repo.delay = const Duration(milliseconds: 50);
    await tester.pumpWidget(_app());
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Daal Chawal Combo'), findsNothing);

    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Daal Chawal Combo'), findsOneWidget);
  });

  testWidgets('a failed fetch offers a retry that recovers', (tester) async {
    repo.throws = true;
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(find.textContaining('Could not load the history'), findsOneWidget);

    repo.throws = false;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.text('Daal Chawal Combo'), findsOneWidget);
  });

  testWidgets('History is the active bottom nav tab and the others navigate',
      (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(find.text('History'), findsOneWidget);

    await tester.tap(find.text('Dishes'));
    await tester.pumpAndSettle();

    expect(find.text('S5'), findsOneWidget);
  });

  testWidgets('rows are not tappable — the spec allows scrolling only',
      (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    final rows = find.ancestor(
      of: find.text('Daal Chawal Combo'),
      matching: find.byType(InkWell),
    );
    expect(rows, findsNothing);
  });

  testWidgets('history keeps the newest record first', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    final first = tester.getTopLeft(find.text('Daal Chawal Combo')).dy;
    final second = tester.getTopLeft(find.text('Beef Nihari')).dy;
    expect(first, lessThan(second));
  });

  testWidgets('the today-relative window is left to the bloc', (tester) async {
    // Guards against the screen filtering by date itself: a record dated far
    // in the past still renders, because the query already scoped the window.
    repo.entries = [
      DayPlanModel(
        id: 'p9',
        date: _today().subtract(const Duration(days: 29)),
        dishId: 'd9',
        dishName: 'Haleem Special',
        categoryName: 'Special',
        status: DayPlanStatus.cooked,
      ),
    ];
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(find.text('Haleem Special'), findsOneWidget);
  });
}
