import '../mock/mock_household_store.dart';
import '../models/day_plan_model.dart';

abstract class WeekPlanRepository {
  Future<List<DayPlanModel>> fetchWeekPlans(String householdId, DateTime from, DateTime to);
  Future<void> updatePlanStatus(String planId, DayPlanStatus status);
}

class SupabaseWeekPlanRepository implements WeekPlanRepository {
  SupabaseWeekPlanRepository();

  final MockHouseholdStore _store = MockHouseholdStore.instance;

  @override
  Future<List<DayPlanModel>> fetchWeekPlans(
    String householdId,
    DateTime from,
    DateTime to,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));

    /* Actual implementation:
    final response = await _supabase
        .from('day_plans')
        .select('id, date, dish_id, status, dishes(name, notes, categories(name))')
        .eq('household_id', householdId)
        .gte('date', from.toIso8601String().substring(0, 10))
        .lte('date', to.toIso8601String().substring(0, 10));

    final Map<String, DayPlanModel> planMap = {};
    for (final row in response as List) {
      final plan = DayPlanModel.fromMap(row);
      planMap[plan.date.toIso8601String().substring(0, 10)] = plan;
    }
    */

    return _store.weekPlans(from, to);
  }

  @override
  Future<void> updatePlanStatus(String planId, DayPlanStatus status) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));

    /* Actual implementation:
    await _supabase
        .from('day_plans')
        .update({'status': status.name})
        .eq('id', planId);
    */

    _store.updatePlanStatus(planId, status);
  }
}
