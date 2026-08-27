import 'package:equatable/equatable.dart';
import '../../../data/models/day_plan_model.dart';

abstract class WeekPlanState extends Equatable {
  const WeekPlanState();
  @override
  List<Object?> get props => [];
}

class WeekPlanInitial extends WeekPlanState {}

class WeekPlanLoading extends WeekPlanState {}

class WeekPlanLoaded extends WeekPlanState {
  final List<DayPlanModel> plans;
  final String householdName;
  final String userRole; // 'planner' | 'member'

  const WeekPlanLoaded({
    required this.plans,
    required this.householdName,
    required this.userRole,
  });

  @override
  List<Object?> get props => [plans, householdName, userRole];
}

class WeekPlanError extends WeekPlanState {
  final String message;
  const WeekPlanError(this.message);
  @override
  List<Object?> get props => [message];
}
