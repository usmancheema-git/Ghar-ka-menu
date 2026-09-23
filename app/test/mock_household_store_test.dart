import 'package:flutter_test/flutter_test.dart';
import 'package:ghar_ka_menu/data/mock/mock_household_store.dart';
import 'package:ghar_ka_menu/data/models/day_plan_model.dart';
import 'package:ghar_ka_menu/data/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// The mock store stands in for Supabase until it is wired up. These cover the
/// two ripples S5/S6 rely on: deleting a dish frees the day it was planned on,
/// and editing a dish refreshes the plan rows that reference it.
void main() {
  final store = MockHouseholdStore.instance;

  // Declared first: the tests below mutate the shared singleton.
  group('S7 history window', () {
    late DateTime from;
    late DateTime to;
    late List<DayPlanModel> history;

    setUp(() {
      from = store.today.subtract(const Duration(days: 30));
      to = store.today.subtract(const Duration(days: 1));
      history = store.plansBetween(from, to);
    });

    test('returns only the seeded past records, newest first', () {
      expect(history.length, 10);
      expect(history.first.dishName, 'Chicken Biryani');
      expect(history.first.date, store.today.subtract(const Duration(days: 1)));
      expect(history.last.dishName, 'Haleem Special');
      expect(history.last.date, store.today.subtract(const Duration(days: 25)));

      final dates = history.map((p) => p.date).toList();
      expect(
        dates,
        orderedEquals(List.of(dates)..sort((a, b) => b.compareTo(a))),
      );
    });

    test('unplanned days are omitted rather than padded', () {
      // Unlike weekPlans, which fabricates an empty row for every gap.
      expect(history.every((p) => !p.isEmpty), isTrue);
      final gap = store.today.subtract(const Duration(days: 3));
      expect(history.map((p) => p.date), isNot(contains(gap)));
      expect(store.weekPlans(gap, gap).single.isEmpty, isTrue);
    });

    test('today and the week ahead stay out of history', () {
      final dates = history.map((p) => p.date).toSet();
      expect(dates, isNot(contains(store.today)));
      expect(dates, isNot(contains(store.today.add(const Duration(days: 1)))));
    });

    test('records older than the window are excluded', () {
      final old = store.today.subtract(const Duration(days: 34));
      expect(history.map((p) => p.date), isNot(contains(old)));
      // It does exist — the window is what leaves it out.
      expect(store.plansBetween(old, to).length, 11);
    });

    test('both outcomes are represented', () {
      final cancelled = history.where((p) => p.wasCancelled).toList();
      expect(
        cancelled.map((p) => p.dishName),
        containsAll(['Karelay Pyaz', 'Bhindi Masala']),
      );
      expect(history.where((p) => !p.wasCancelled).length, 8);
    });
  });

  test('mock auth flow updates the active household and role state', () async {
    final repo = SupabaseAuthRepository(
      SupabaseClient('https://mock.supabase.co', 'mock_key'),
    );

    await repo.authenticateWithEmail(
      'awais@example.com',
      'password123',
      createAccount: false,
    );
    await repo.createHousehold('Khan Family', 'Awais');
    expect(MockHouseholdStore.isAuthenticated, isTrue);
    expect(MockHouseholdStore.householdName, 'Khan Family');
    expect(MockHouseholdStore.userRole, 'planner');

    await repo.joinHousehold('123456', 'Bilal');
    expect(MockHouseholdStore.userRole, 'member');
    expect(MockHouseholdStore.isAuthenticated, isTrue);
    expect(MockHouseholdStore.householdId, isNotEmpty);
  });

  test(
    'joining by code resolves the real household and rejects invalid codes',
    () async {
      final repo = SupabaseAuthRepository(
        SupabaseClient('https://mock.supabase.co', 'mock_key'),
      );

      await repo.authenticateWithEmail(
        'awais@example.com',
        'password123',
        createAccount: false,
      );
      await repo.createHousehold('Awais Family', 'Awais');

      final householdCode = '482910';
      await repo.joinHousehold(householdCode, 'Bilal');
      expect(MockHouseholdStore.householdName, 'Awais Family');
      expect(MockHouseholdStore.userRole, 'member');

      await expectLater(
        repo.joinHousehold('999999', 'Maryam'),
        throwsA(isA<Exception>()),
      );
    },
  );

  test(
    'week plan uses the current household name from the signed-in session',
    () async {
      MockHouseholdStore.setSession(
        householdIdValue: 'household-live-42',
        householdNameValue: 'Green Valley Family',
        role: 'planner',
        authenticated: true,
      );

      expect(MockHouseholdStore.householdName, 'Green Valley Family');
      expect(MockHouseholdStore.householdId, 'household-live-42');
    },
  );

  test(
    'a new dish is listed alphabetically and starts as never cooked',
    () async {
      final created = store.addDish(name: 'Aloo Gobi', categoryId: 'c1');

      expect(created.categoryName, 'Sabzi');
      expect(created.timesCooked, 0);
      expect(created.lastCookedOn, isNull);
      expect(created.managerSubtitle, 'Sabzi · Never Cooked');

      final names = store.dishesSortedByName().map((d) => d.name).toList();
      expect(names.first, 'Aloo Gobi');
      expect(names, orderedEquals(List.of(names)..sort()));
    },
  );

  test('editing a dish keeps its cooking history', () {
    final before = store.dishById('d5')!;
    final updated = store.updateDish(
      id: 'd5',
      name: 'Chicken Biryani (Sindhi)',
      categoryId: 'c3',
      ingredientsText: 'Chicken, Rice',
      notes: null,
    );

    expect(updated.name, 'Chicken Biryani (Sindhi)');
    expect(updated.timesCooked, before.timesCooked);
    expect(updated.lastCookedOn, before.lastCookedOn);
    expect(updated.notes, isNull);
  });

  test('editing a dish refreshes the week plan rows that use it', () {
    final date = store.today.add(const Duration(days: 1));
    expect(store.weekPlans(date, date).single.dishId, 'd5');

    store.updateDish(
      id: 'd5',
      name: 'Beef Biryani',
      categoryId: 'c4',
      ingredientsText: null,
      notes: 'Marinate overnight.',
    );

    final plan = store.weekPlans(date, date).single;
    expect(plan.dishName, 'Beef Biryani');
    expect(plan.categoryName, 'Gosht');
    expect(plan.dishNotes, 'Marinate overnight.');
    expect(plan.status, DayPlanStatus.planned);
  });

  test('deleting a scheduled dish leaves that day unassigned', () {
    final date = store.today.add(const Duration(days: 1));
    expect(store.plannedDishIds(date, date), contains('d5'));

    store.deleteDish('d5');

    expect(store.dishById('d5'), isNull);
    final plan = store.weekPlans(date, date).single;
    expect(plan.dishId, isNull);
    expect(plan.dishName, isNull);
    expect(plan.isEmpty, isTrue);
    expect(plan.status, isNull);
    expect(store.plannedDishIds(date, date), isNot(contains('d5')));
  });

  test('deleting an unscheduled dish leaves the rest of the week alone', () {
    final from = store.today;
    final to = from.add(const Duration(days: 6));
    final before = store.plannedDishIds(from, to);

    store.deleteDish('d3'); // Chicken Pulao — not on the plan

    expect(store.dishById('d3'), isNull);
    expect(store.plannedDishIds(from, to), before);
  });
}
