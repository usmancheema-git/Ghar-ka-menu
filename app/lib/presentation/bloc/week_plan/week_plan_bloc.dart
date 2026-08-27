import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/week_plan_repository.dart';
import 'week_plan_event.dart';
import 'week_plan_state.dart';

class WeekPlanBloc extends Bloc<WeekPlanEvent, WeekPlanState> {
  final WeekPlanRepository _repository;

  // Hard-coded for prototype; will come from auth session in production
  static const String _householdId = 'household-mock-id';
  static const String _householdName = 'Awais Family';
  static const String _userRole = 'planner';

  WeekPlanBloc({required WeekPlanRepository repository})
      // ignore: prefer_initializing_formals
      : _repository = repository,
        super(WeekPlanInitial()) {
    on<LoadWeekPlan>(_onLoad);
    on<UpdateDayStatus>(_onUpdateStatus);
  }

  Future<void> _onLoad(LoadWeekPlan event, Emitter<WeekPlanState> emit) async {
    emit(WeekPlanLoading());
    try {
      final today = _today();
      final plans = await _repository.fetchWeekPlans(
        _householdId,
        today,
        today.add(const Duration(days: 6)),
      );
      emit(WeekPlanLoaded(
        plans: plans,
        householdName: _householdName,
        userRole: _userRole,
      ));
    } catch (e) {
      emit(WeekPlanError(e.toString()));
    }
  }

  Future<void> _onUpdateStatus(
    UpdateDayStatus event,
    Emitter<WeekPlanState> emit,
  ) async {
    final current = state;
    if (current is! WeekPlanLoaded) return;

    // Optimistically update UI before network call
    final updated = current.plans.map((p) {
      return p.id == event.planId ? p.copyWith(status: event.status) : p;
    }).toList();
    emit(WeekPlanLoaded(
      plans: updated,
      householdName: current.householdName,
      userRole: current.userRole,
    ));

    try {
      await _repository.updatePlanStatus(event.planId, event.status);
    } catch (e) {
      // Roll back on failure
      emit(current);
      emit(WeekPlanError('Failed to update status: ${e.toString()}'));
    }
  }

  DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }
}
