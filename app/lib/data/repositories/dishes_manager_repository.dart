import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

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

abstract interface class DishesManagerRealtimeRepository {
  Stream<void> watchChanges(String householdId);
}

class SupabaseDishesManagerRepository
    implements DishesManagerRepository, DishesManagerRealtimeRepository {
  SupabaseDishesManagerRepository(this._supabase);

  final SupabaseClient? _supabase;
  final MockHouseholdStore _store = MockHouseholdStore.instance;

  @override
  Future<List<CategoryModel>> fetchCategories(String householdId) async {
    if (_supabase != null) {
      final response = await _supabase
          .from('categories')
          .select()
          .eq('household_id', householdId)
          .order('sort_order');
      return response.map((row) => CategoryModel.fromMap(row)).toList();
    }

    await Future<void>.delayed(const Duration(milliseconds: 300));

    return List<CategoryModel>.from(_store.categories);
  }

  @override
  Future<List<DishModel>> fetchDishes(String householdId) async {
    if (_supabase != null) {
      final response = await _supabase
          .from('dishes')
          .select(
            'id, name, category_id, ingredients_text, notes, last_cooked_on, times_cooked, categories(name)',
          )
          .eq('household_id', householdId)
          .order('name');
      return response.map((row) => DishModel.fromMap(row)).toList();
    }

    await Future<void>.delayed(const Duration(milliseconds: 500));

    return _store.dishesSortedByName();
  }

  @override
  Future<List<String>> fetchScheduledDishIds({
    required String householdId,
    required DateTime from,
    required DateTime to,
  }) async {
    if (_supabase != null) {
      final response = await _supabase
          .from('day_plans')
          .select('dish_id')
          .eq('household_id', householdId)
          .gte('date', from.toIso8601String().substring(0, 10))
          .lte('date', to.toIso8601String().substring(0, 10));
      return response
          .map((row) => row['dish_id'] as String?)
          .whereType<String>()
          .toSet()
          .toList();
    }

    await Future<void>.delayed(const Duration(milliseconds: 200));

    return _store.plannedDishIds(from, to);
  }

  @override
  Future<void> deleteDish({
    required String householdId,
    required String dishId,
  }) async {
    if (_supabase != null) {
      await _supabase
          .from('dishes')
          .delete()
          .eq('household_id', householdId)
          .eq('id', dishId);
      return;
    }

    await Future<void>.delayed(const Duration(milliseconds: 400));

    _store.deleteDish(dishId);
  }

  @override
  Stream<void> watchChanges(String householdId) {
    final supabase = _supabase;
    if (supabase == null) return const Stream<void>.empty();

    final changes = StreamController<void>.broadcast();
    final channel = supabase.channel('dishes-$householdId');
    for (final table in ['dishes', 'categories', 'day_plans']) {
      channel.onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: table,
        callback: (_) => changes.add(null),
      );
    }
    channel.subscribe();

    changes.onCancel = () async {
      await supabase.removeChannel(channel);
      await changes.close();
    };
    return changes.stream;
  }
}
