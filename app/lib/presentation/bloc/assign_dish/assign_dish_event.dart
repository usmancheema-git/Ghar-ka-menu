import 'package:equatable/equatable.dart';

abstract class AssignDishEvent extends Equatable {
  const AssignDishEvent();
  @override
  List<Object?> get props => [];
}

class LoadAssignDishData extends AssignDishEvent {
  final String householdId;

  const LoadAssignDishData({required this.householdId});

  @override
  List<Object?> get props => [householdId];
}

class FilterByCategory extends AssignDishEvent {
  final String? categoryId; // null means 'All'
  const FilterByCategory(this.categoryId);
  @override
  List<Object?> get props => [categoryId];
}

class SearchDishes extends AssignDishEvent {
  final String query;
  const SearchDishes(this.query);
  @override
  List<Object?> get props => [query];
}

class AssignDishToDay extends AssignDishEvent {
  final String dishId;
  final String householdId;
  final DateTime date;

  const AssignDishToDay({
    required this.dishId,
    required this.householdId,
    required this.date,
  });

  @override
  List<Object?> get props => [dishId, householdId, date];
}
