import 'package:equatable/equatable.dart';

abstract class DishDetailEvent extends Equatable {
  const DishDetailEvent();
  @override
  List<Object?> get props => [];
}

class LoadDishDetail extends DishDetailEvent {
  final String dishId;
  final String householdId;

  const LoadDishDetail({required this.dishId, required this.householdId});

  @override
  List<Object?> get props => [dishId, householdId];
}
