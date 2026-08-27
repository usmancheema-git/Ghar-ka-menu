import '../mock/mock_household_store.dart';
import '../models/category_model.dart';
import '../models/dish_model.dart';

/// S5 Dishes Manager — reads the dish/category library and deletes dishes.
abstract class DishesManagerRepository {
  Future<List<CategoryModel>> fetchCategories(String householdId);

  /// All household dishes, alphabetical (the manager is a database listing —
  /// score sorting is specific to S3 Assign Dish).
  Future<List<DishModel>> fetchDishes(String householdId);

  /// Dish IDs booked in [from]..[to], used to warn before deleting a dish that
  /// is still on the week plan.
  Future<List<String>> fetchScheduledDishIds({
    required String householdId,
    required DateTime from,
    required DateTime to,
  });

  Future<void> deleteDish({
    required String householdId,
    required String dishId,
  });
}

class SupabaseDishesManagerRepository implements DishesManagerRepository {
  SupabaseDishesManagerRepository();

  final MockHouseholdStore _store = MockHouseholdStore.instance;

  @override
  Future<List<CategoryModel>> fetchCategories(String householdId) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));

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
    await Future<void>.delayed(const Duration(milliseconds: 500));

    /* Actual implementation:
    final response = await _supabase
        .from('dishes')
        .select('id, name, category_id, ingredients_text, notes, '
            'last_cooked_on, times_cooked, categories(name)')
        .eq('household_id', householdId)
        .order('name');
    return (response as List).map((e) => DishModel.fromMap(e)).toList();
    */

    return _store.dishesSortedByName();
  }

  @override
  Future<List<String>> fetchScheduledDishIds({
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
  Future<void> deleteDish({
    required String householdId,
    required String dishId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));

    /* Actual implementation (day_plans.dish_id is ON DELETE SET NULL):
    await _supabase
        .from('dishes')
        .delete()
        .eq('household_id', householdId)
        .eq('id', dishId);
    */

    _store.deleteDish(dishId);
  }
}
