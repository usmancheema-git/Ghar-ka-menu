import 'package:flutter_test/flutter_test.dart';
import 'package:ghar_ka_menu/data/mock/mock_household_store.dart';
import 'package:ghar_ka_menu/data/models/day_plan_model.dart';

/// The mock store stands in for Supabase until it is wired up. These cover the
/// two ripples S5/S6 rely on: deleting a dish frees the day it was planned on,
/// and editing a dish refreshes the plan rows that reference it.
void main() {
  final store = MockHouseholdStore.instance;

  test('a new dish is listed alphabetically and starts as never cooked', () async {
    final created = store.addDish(name: 'Aloo Gobi', categoryId: 'c1');

    expect(created.categoryName, 'Sabzi');
    expect(created.timesCooked, 0);
    expect(created.lastCookedOn, isNull);
    expect(created.managerSubtitle, 'Sabzi · Never Cooked');

    final names = store.dishesSortedByName().map((d) => d.name).toList();
    expect(names.first, 'Aloo Gobi');
    expect(names, orderedEquals(List.of(names)..sort()));
  });

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
