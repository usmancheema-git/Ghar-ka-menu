import 'package:equatable/equatable.dart';
import '../../../data/models/dish_model.dart';

abstract class DishDetailState extends Equatable {
  const DishDetailState();
  @override
  List<Object?> get props => [];
}

class DishDetailInitial extends DishDetailState {}

class DishDetailLoading extends DishDetailState {}

class DishDetailLoaded extends DishDetailState {
  final DishModel dish;

  const DishDetailLoaded({required this.dish});

  @override
  List<Object?> get props => [dish];
}

class DishDetailError extends DishDetailState {
  final String message;
  const DishDetailError(this.message);
  @override
  List<Object?> get props => [message];
}
