import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/dish_detail_repository.dart';
import 'dish_detail_event.dart';
import 'dish_detail_state.dart';

class DishDetailBloc extends Bloc<DishDetailEvent, DishDetailState> {
  final DishDetailRepository _repository;

  DishDetailBloc({required DishDetailRepository repository})
      // ignore: prefer_initializing_formals
      : _repository = repository,
        super(DishDetailInitial()) {
    on<LoadDishDetail>(_onLoad);
  }

  Future<void> _onLoad(
    LoadDishDetail event,
    Emitter<DishDetailState> emit,
  ) async {
    emit(DishDetailLoading());
    try {
      final dish = await _repository.fetchDishById(
        householdId: event.householdId,
        dishId: event.dishId,
      );
      if (dish == null) {
        emit(const DishDetailError('Dish not found'));
        return;
      }
      emit(DishDetailLoaded(dish: dish));
    } catch (e) {
      emit(DishDetailError(e.toString()));
    }
  }
}
