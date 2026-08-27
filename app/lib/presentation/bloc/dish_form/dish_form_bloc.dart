import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/dish_form_repository.dart';
import 'dish_form_event.dart';
import 'dish_form_state.dart';

class DishFormBloc extends Bloc<DishFormEvent, DishFormState> {
  final DishFormRepository _repository;

  DishFormBloc({required DishFormRepository repository})
      // ignore: prefer_initializing_formals
      : _repository = repository,
        super(DishFormInitial()) {
    on<LoadDishForm>(_onLoad);
    on<SubmitDishForm>(_onSubmit);
  }

  Future<void> _onLoad(LoadDishForm event, Emitter<DishFormState> emit) async {
    emit(DishFormLoading());
    try {
      final categories = await _repository.fetchCategories(event.householdId);
      if (event.dishId == null) {
        emit(DishFormReady(categories: categories));
        return;
      }
      final dish = await _repository.fetchDish(
        householdId: event.householdId,
        dishId: event.dishId!,
      );
      if (dish == null) {
        emit(const DishFormError('Dish not found'));
        return;
      }
      emit(DishFormReady(categories: categories, dish: dish));
    } catch (e) {
      emit(DishFormError(e.toString()));
    }
  }

  Future<void> _onSubmit(
    SubmitDishForm event,
    Emitter<DishFormState> emit,
  ) async {
    final current = state;
    if (current is! DishFormReady || current.isSubmitting) return;

    final name = event.name.trim();
    final nameError = name.isEmpty ? 'Dish name is required' : null;
    final categoryError =
        event.categoryId == null ? 'Pick a category' : null;
    if (nameError != null || categoryError != null) {
      // Built directly rather than through copyWith: copyWith cannot both drop
      // the previous errors and set new ones in the same call.
      emit(DishFormReady(
        categories: current.categories,
        dish: current.dish,
        nameError: nameError,
        categoryError: categoryError,
      ));
      return;
    }

    final ingredients = event.ingredientsText.trim();
    final notes = event.notes.trim();

    emit(current.copyWith(isSubmitting: true, clearErrors: true));
    try {
      if (current.isEditMode) {
        await _repository.updateDish(
          householdId: event.householdId,
          dishId: current.dish!.id,
          name: name,
          categoryId: event.categoryId!,
          ingredientsText: ingredients.isEmpty ? null : ingredients,
          notes: notes.isEmpty ? null : notes,
        );
      } else {
        await _repository.createDish(
          householdId: event.householdId,
          name: name,
          categoryId: event.categoryId!,
          ingredientsText: ingredients.isEmpty ? null : ingredients,
          notes: notes.isEmpty ? null : notes,
        );
      }
      emit(DishFormSaved());
    } catch (e) {
      emit(current.copyWith(
        isSubmitting: false,
        submitError: 'Could not save the dish: ${e.toString()}',
      ));
    }
  }
}
