import 'package:equatable/equatable.dart';

abstract class HistoryEvent extends Equatable {
  const HistoryEvent();
  @override
  List<Object?> get props => [];
}

class LoadHistory extends HistoryEvent {
  final String householdId;

  const LoadHistory({required this.householdId});

  @override
  List<Object?> get props => [householdId];
}

class ReloadHistory extends HistoryEvent {
  final String householdId;

  const ReloadHistory({required this.householdId});

  @override
  List<Object?> get props => [householdId];
}
