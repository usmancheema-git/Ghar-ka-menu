import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/dish_model.dart';
import '../../../data/repositories/assign_dish_repository.dart';
import 'assign_dish_event.dart';
import 'assign_dish_state.dart';

class AssignDishBloc extends Bloc<AssignDishEvent, AssignDishState> {
  final AssignDishRepository _repository;

  AssignDishBloc({required AssignDishRepository repository})
      // ignore: prefer_initializing_formals
      : _repository = repository,
        super(AssignDishInitial()) {
    on<LoadAssignDishData>(_onLoad);
    on<FilterByCategory>(_onFilter);
    on<SearchDishes>(_onSearch);
    on<AssignDishToDay>(_onAssign);
  }

  Future<void> _onLoad(
    LoadAssignDishData event,
    Emitter<AssignDishState> emit,
  ) async {
    emit(AssignDishLoading());
    try {
      final today = _today();
      final windowEnd = today.add(const Duration(days: 6));
      final categories = await _repository.fetchCategories(event.householdId);
      final dishes = await _repository.fetchDishes(event.householdId);
      final plannedIds = await _repository.fetchPlannedDishIds(
        householdId: event.householdId,
        from: today,
        to: windowEnd,
      );
      emit(AssignDishLoaded(
        allDishes: dishes,
        filteredDishes: dishes,
        categories: categories,
        alreadyPlannedDishIds: plannedIds,
      ));
    } catch (e) {
      emit(AssignDishError(e.toString()));
    }
  }

  void _onFilter(FilterByCategory event, Emitter<AssignDishState> emit) {
    final current = state;
    if (current is! AssignDishLoaded || current.isAssigning) return;

    final filtered = _applyFilters(
      all: current.allDishes,
      categoryId: event.categoryId,
      query: current.searchQuery,
    );
    emit(current.copyWith(
      filteredDishes: filtered,
      selectedCategoryId: event.categoryId,
      clearCategory: event.categoryId == null,
      clearActionError: true,
    ));
  }

  void _onSearch(SearchDishes event, Emitter<AssignDishState> emit) {
    final current = state;
    if (current is! AssignDishLoaded || current.isAssigning) return;

    final filtered = _applyFilters(
      all: current.allDishes,
      categoryId: current.selectedCategoryId,
      query: event.query,
    );
    emit(current.copyWith(
      filteredDishes: filtered,
      searchQuery: event.query,
      clearActionError: true,
    ));
  }

  Future<void> _onAssign(
    AssignDishToDay event,
    Emitter<AssignDishState> emit,
  ) async {
    final current = state;
    if (current is! AssignDishLoaded || current.isAssigning) return;

    emit(current.copyWith(isAssigning: true, clearActionError: true));
    try {
      await _repository.assignDish(
        householdId: event.householdId,
        dishId: event.dishId,
        date: event.date,
      );
      emit(AssignDishSuccess());
    } catch (e) {
      emit(current.copyWith(isAssigning: false, actionError: e.toString()));
    }
  }

  List<DishModel> _applyFilters({
    required List<DishModel> all,
    required String? categoryId,
    required String query,
  }) {
    var result = all;
    if (categoryId != null) {
      result = result.where((d) => d.categoryId == categoryId).toList();
    }
    if (query.isNotEmpty) {
      final q = query.toLowerCase();
      result = result.where((d) => d.name.toLowerCase().contains(q)).toList();
    }
    return result;
  }

  DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }
}
