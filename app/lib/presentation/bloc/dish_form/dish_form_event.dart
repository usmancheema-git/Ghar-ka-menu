import 'package:equatable/equatable.dart';

abstract class DishFormEvent extends Equatable {
  const DishFormEvent();
  @override
  List<Object?> get props => [];
}

class LoadDishForm extends DishFormEvent {
  final String householdId;

  /// null opens an empty form (Add mode).
  final String? dishId;

  const LoadDishForm({required this.householdId, this.dishId});

  @override
  List<Object?> get props => [householdId, dishId];
}

class SubmitDishForm extends DishFormEvent {
  final String householdId;
  final String name;
  final String? categoryId;
  final String ingredientsText;
  final String notes;

  const SubmitDishForm({
    required this.householdId,
    required this.name,
    required this.categoryId,
    required this.ingredientsText,
    required this.notes,
  });

  @override
  List<Object?> get props =>
      [householdId, name, categoryId, ingredientsText, notes];
}
