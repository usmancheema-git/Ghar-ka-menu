import 'package:supabase_flutter/supabase_flutter.dart';

import '../mock/mock_household_store.dart';
import '../models/dish_model.dart';

abstract class DishDetailRepository {
  /// Returns null when the dish does not exist in this household.
  Future<DishModel?> fetchDishById({
    required String householdId,
    required String dishId,
  });
}

class SupabaseDishDetailRepository implements DishDetailRepository {
  SupabaseDishDetailRepository(this._supabase);

  final SupabaseClient? _supabase;
  final MockHouseholdStore _store = MockHouseholdStore.instance;

  @override
  Future<DishModel?> fetchDishById({
    required String householdId,
    required String dishId,
  }) async {
    if (_supabase != null) {
      final response = await _supabase
          .from('dishes')
          .select(
            'id, name, category_id, ingredients_text, notes, last_cooked_on, times_cooked, categories(name)',
          )
          .eq('household_id', householdId)
          .eq('id', dishId)
          .maybeSingle();
      if (response == null) return null;
      return DishModel.fromMap(response);
    }

    await Future<void>.delayed(const Duration(milliseconds: 400));

    return _store.dishById(dishId);
  }
}
