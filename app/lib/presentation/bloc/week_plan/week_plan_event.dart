import 'package:equatable/equatable.dart';
import '../../../data/models/day_plan_model.dart';

abstract class WeekPlanEvent extends Equatable {
  const WeekPlanEvent();
  @override
  List<Object?> get props => [];
}

class LoadWeekPlan extends WeekPlanEvent {}

class UpdateDayStatus extends WeekPlanEvent {
  final String planId;
  final DayPlanStatus status;
  const UpdateDayStatus({required this.planId, required this.status});
  @override
  List<Object?> get props => [planId, status];
}
