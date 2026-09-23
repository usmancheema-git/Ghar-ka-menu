import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/week_plan_repository.dart';
import '../data/repositories/assign_dish_repository.dart';
import '../data/repositories/dish_detail_repository.dart';
import '../data/repositories/dishes_manager_repository.dart';
import '../data/repositories/dish_form_repository.dart';
import '../data/repositories/history_repository.dart';
import '../data/repositories/household_repository.dart';

final getIt = GetIt.instance;

void setupDependencies({SupabaseClient? supabase}) {
  getIt.registerLazySingleton<AuthRepository>(
    () => SupabaseAuthRepository(supabase, live: supabase != null),
  );
  getIt.registerLazySingleton<WeekPlanRepository>(
    () => SupabaseWeekPlanRepository(supabase),
  );
  getIt.registerLazySingleton<AssignDishRepository>(
    () => SupabaseAssignDishRepository(supabase),
  );
  getIt.registerLazySingleton<DishDetailRepository>(
    () => SupabaseDishDetailRepository(supabase),
  );
  getIt.registerLazySingleton<DishesManagerRepository>(
    () => SupabaseDishesManagerRepository(supabase),
  );
  getIt.registerLazySingleton<DishFormRepository>(
    () => SupabaseDishFormRepository(supabase),
  );
  getIt.registerLazySingleton<HistoryRepository>(
    () => SupabaseHistoryRepository(supabase),
  );
  getIt.registerLazySingleton<HouseholdRepository>(
    () => SupabaseHouseholdRepository(supabase),
  );
}
