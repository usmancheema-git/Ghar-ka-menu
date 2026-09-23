import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import '../data/mock/mock_household_store.dart';
import '../presentation/screens/s1_onboarding/s1_onboarding_screen.dart';
import '../presentation/screens/s2_week_view/s2_week_view_screen.dart';
import '../presentation/screens/s3_assign_dish/s3_assign_dish_screen.dart';
import '../presentation/screens/s4_dish_detail/s4_dish_detail_screen.dart';
import '../presentation/screens/s5_dishes_manager/s5_dishes_manager_screen.dart';
import '../presentation/screens/s6_add_edit_dish/s6_add_edit_dish_screen.dart';
import '../presentation/screens/s7_history/s7_history_screen.dart';
import '../presentation/screens/s8_settings/s8_settings_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/onboarding',
  redirect: (context, state) {
    final authenticated = MockHouseholdStore.isAuthenticated;
    if (authenticated &&
        const {
          '/onboarding',
          '/login',
          '/signup',
        }.contains(state.matchedLocation)) {
      return '/home';
    }
    return null;
  },
  routes: [
    GoRoute(path: '/onboarding', redirect: (_, _) => '/login'),
    GoRoute(
      path: '/login',
      builder: (context, state) => const S1OnboardingScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const S1OnboardingScreen(signupMode: true),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const S2WeekViewScreen(),
    ),
    GoRoute(
      path: '/assign/:date',
      builder: (context, state) {
        final date =
            state.pathParameters['date'] ??
            DateTime.now().toIso8601String().substring(0, 10);
        return S3AssignDishScreen(date: date);
      },
    ),
    GoRoute(
      path: '/dish/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        // Keyed by id so the bloc reloads when the location changes dish.
        return S4DishDetailScreen(key: ValueKey(id), dishId: id);
      },
    ),
    GoRoute(
      path: '/dishes',
      builder: (context, state) => const S5DishesManagerScreen(),
    ),
    GoRoute(
      path: '/dishes/new',
      builder: (context, state) => const S6AddEditDishScreen(),
    ),
    GoRoute(
      path: '/dishes/edit/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        // Keyed by id so the bloc reloads when the location changes dish.
        return S6AddEditDishScreen(key: ValueKey(id), dishId: id);
      },
    ),
    GoRoute(
      path: '/history',
      builder: (context, state) => const S7HistoryScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const S8SettingsScreen(),
    ),
  ],
);
