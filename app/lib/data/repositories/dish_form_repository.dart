import '../mock/mock_household_store.dart';
import '../models/category_model.dart';
import '../models/dish_model.dart';

/// S6 Add/Edit Dish — populates the category dropdown and writes the dish row.
abstract class DishFormRepository {
  Future<List<CategoryModel>> fetchCategories(String householdId);

  /// Existing row for Edit mode. Returns null when the dish is gone.
  Future<DishModel?> fetchDish({
    required String householdId,
    required String dishId,
  });

  Future<void> createDish({
    required String householdId,
    required String name,
    required String categoryId,
    String? ingredientsText,
    String? notes,
  });

  Future<void> updateDish({
    required String householdId,
    required String dishId,
    required String name,
    required String categoryId,
    String? ingredientsText,
    String? notes,
  });
}

class SupabaseDishFormRepository implements DishFormRepository {
  SupabaseDishFormRepository();

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
  Future<DishModel?> fetchDish({
    required String householdId,
    required String dishId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));

    /* Actual implementation:
    final response = await _supabase
        .from('dishes')
        .select('id, name, category_id, ingredients_text, notes, '
            'last_cooked_on, times_cooked, categories(name)')
        .eq('household_id', householdId)
        .eq('id', dishId)
        .maybeSingle();
    if (response == null) return null;
    return DishModel.fromMap(response);
    */

    return _store.dishById(dishId);
  }

  @override
  Future<void> createDish({
    required String householdId,
    required String name,
    required String categoryId,
    String? ingredientsText,
    String? notes,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));

    /* Actual implementation:
    await _supabase.from('dishes').insert({
      'household_id': householdId,
      'category_id': categoryId,
      'name': name,
      'ingredients_text': ingredientsText,
      'notes': notes,
    });
    */

    _store.addDish(
      name: name,
      categoryId: categoryId,
      ingredientsText: ingredientsText,
      notes: notes,
    );
  }

  @override
  Future<void> updateDish({
    required String householdId,
    required String dishId,
    required String name,
    required String categoryId,
    String? ingredientsText,
    String? notes,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));

    /* Actual implementation:
    await _supabase
        .from('dishes')
        .update({
          'category_id': categoryId,
          'name': name,
          'ingredients_text': ingredientsText,
          'notes': notes,
        })
        .eq('household_id', householdId)
        .eq('id', dishId);
    */

    _store.updateDish(
      id: dishId,
      name: name,
      categoryId: categoryId,
      ingredientsText: ingredientsText,
      notes: notes,
    );
  }
}
