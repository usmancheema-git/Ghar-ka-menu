import 'package:equatable/equatable.dart';
import '../../../data/models/day_plan_model.dart';

abstract class HistoryState extends Equatable {
  const HistoryState();
  @override
  List<Object?> get props => [];
}

class HistoryInitial extends HistoryState {}

class HistoryLoading extends HistoryState {}

class HistoryLoaded extends HistoryState {
  /// Past lunch records, newest first.
  final List<DayPlanModel> entries;

  const HistoryLoaded(this.entries);

  /// True on a fresh install — nothing has been planned yet.
  bool get hasNoHistory => entries.isEmpty;

  @override
  List<Object?> get props => [entries];
}

class HistoryError extends HistoryState {
  final String message;
  const HistoryError(this.message);
  @override
  List<Object?> get props => [message];
}
