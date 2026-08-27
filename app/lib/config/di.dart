import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/week_plan_repository.dart';
import '../data/repositories/assign_dish_repository.dart';
import '../data/repositories/dish_detail_repository.dart';
import '../data/repositories/dishes_manager_repository.dart';
import '../data/repositories/dish_form_repository.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  // Wait to initialize Supabase until we have the URL and Key.
  // For now we mock the client dependency.
  // getIt.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);
  
  // Repositories
  // getIt.registerLazySingleton<AuthRepository>(() => SupabaseAuthRepository(getIt()));
  
  // Temporarily registering the repo with a null client since we mocked the methods for prototype.
  getIt.registerLazySingleton<AuthRepository>(() => SupabaseAuthRepository(SupabaseClient('https://mock.supabase.co', 'mock_key')));
  getIt.registerLazySingleton<WeekPlanRepository>(() => SupabaseWeekPlanRepository());
  getIt.registerLazySingleton<AssignDishRepository>(() => SupabaseAssignDishRepository());
  getIt.registerLazySingleton<DishDetailRepository>(() => SupabaseDishDetailRepository());
  getIt.registerLazySingleton<DishesManagerRepository>(() => SupabaseDishesManagerRepository());
  getIt.registerLazySingleton<DishFormRepository>(() => SupabaseDishFormRepository());
}
