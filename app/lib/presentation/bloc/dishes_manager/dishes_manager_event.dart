import 'package:equatable/equatable.dart';

abstract class DishesManagerEvent extends Equatable {
  const DishesManagerEvent();
  @override
  List<Object?> get props => [];
}

class LoadDishesManager extends DishesManagerEvent {
  final String householdId;

  const LoadDishesManager({required this.householdId});

  @override
  List<Object?> get props => [householdId];
}

class ReloadDishesManager extends DishesManagerEvent {
  final String householdId;

  const ReloadDishesManager({required this.householdId});

  @override
  List<Object?> get props => [householdId];
}

class FilterManagerByCategory extends DishesManagerEvent {
  final String? categoryId; // null means 'All'
  const FilterManagerByCategory(this.categoryId);
  @override
  List<Object?> get props => [categoryId];
}

class SearchManagerDishes extends DishesManagerEvent {
  final String query;
  const SearchManagerDishes(this.query);
  @override
  List<Object?> get props => [query];
}

class DeleteManagerDish extends DishesManagerEvent {
  final String dishId;
  final String householdId;

  const DeleteManagerDish({required this.dishId, required this.householdId});

  @override
  List<Object?> get props => [dishId, householdId];
}
