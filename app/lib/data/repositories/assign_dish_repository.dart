import '../mock/mock_household_store.dart';
import '../models/category_model.dart';
import '../models/dish_model.dart';

abstract class AssignDishRepository {
  Future<List<CategoryModel>> fetchCategories(String householdId);
  Future<List<DishModel>> fetchDishes(String householdId);
  Future<List<String>> fetchPlannedDishIds({
    required String householdId,
    required DateTime from,
    required DateTime to,
  });
  Future<void> assignDish({
    required String householdId,
    required String dishId,
    required DateTime date,
  });
}

class SupabaseAssignDishRepository implements AssignDishRepository {
  SupabaseAssignDishRepository();

  final MockHouseholdStore _store = MockHouseholdStore.instance;

  @override
  Future<List<CategoryModel>> fetchCategories(String householdId) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));

    /* Actual implementation:
    final response = await _supabase
        .from('categories')
        .select()
        .eq('household_id', householdId)
        .order('sort_order');
    return (response as List).map((e) => CategoryModel.fromMap(e)).toList();
    */

    return List<CategoryModel>.from(_store.categories);
  }

  @override
  Future<List<DishModel>> fetchDishes(String householdId) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));

    /* Actual implementation:
    final response = await _supabase
        .from('dishes')
        .select('id, name, category_id, notes, last_cooked_on, times_cooked, categories(name)')
        .eq('household_id', householdId);
    final dishes = (response as List).map((e) => DishModel.fromMap(e)).toList();
    dishes.sort((a, b) => b.score.compareTo(a.score));
    return dishes;
    */

    return _store.dishesSortedByScore();
  }

  @override
  Future<List<String>> fetchPlannedDishIds({
    required String householdId,
    required DateTime from,
    required DateTime to,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));

    /* Actual implementation:
    final response = await _supabase
        .from('day_plans')
        .select('dish_id')
        .eq('household_id', householdId)
        .gte('date', from.toIso8601String().substring(0, 10))
        .lte('date', to.toIso8601String().substring(0, 10));
    return (response as List)
        .map((e) => e['dish_id'] as String?)
        .whereType<String>()
        .toSet()
        .toList();
    */

    return _store.plannedDishIds(from, to);
  }

  @override
  Future<void> assignDish({
    required String householdId,
    required String dishId,
    required DateTime date,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));

    /* Actual implementation (upsert so editing a day also works):
    await _supabase.from('day_plans').upsert({
      'household_id': householdId,
      'dish_id': dishId,
      'date': date.toIso8601String().substring(0, 10),
      'status': 'planned',
    }, onConflict: 'household_id, date');
    */

    _store.upsertDayPlan(dishId: dishId, date: date);
  }
}
