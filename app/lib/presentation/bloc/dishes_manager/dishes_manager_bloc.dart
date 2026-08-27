import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/mock/mock_household_store.dart';
import '../../../data/models/dish_model.dart';
import '../../../data/repositories/dishes_manager_repository.dart';
import 'dishes_manager_event.dart';
import 'dishes_manager_state.dart';

class DishesManagerBloc extends Bloc<DishesManagerEvent, DishesManagerState> {
  final DishesManagerRepository _repository;

  DishesManagerBloc({required DishesManagerRepository repository})
      // ignore: prefer_initializing_formals
      : _repository = repository,
        super(DishesManagerInitial()) {
    on<LoadDishesManager>(_onLoad);
    on<FilterManagerByCategory>(_onFilter);
    on<SearchManagerDishes>(_onSearch);
    on<DeleteManagerDish>(_onDelete);
  }

  Future<void> _onLoad(
    LoadDishesManager event,
    Emitter<DishesManagerState> emit,
  ) async {
    // Keep the current filters across a reload (e.g. returning from S6).
    final previous = state is DishesManagerLoaded
        ? state as DishesManagerLoaded
        : null;
    emit(DishesManagerLoading());
    try {
      final today = _today();
      final categories = await _repository.fetchCategories(event.householdId);
      final dishes = await _repository.fetchDishes(event.householdId);
      final scheduledIds = await _repository.fetchScheduledDishIds(
        householdId: event.householdId,
        from: today,
        to: today.add(const Duration(days: 6)),
      );
      final categoryId = categories.any((c) => c.id == previous?.selectedCategoryId)
          ? previous?.selectedCategoryId
          : null;
      final query = previous?.searchQuery ?? '';
      emit(DishesManagerLoaded(
        allDishes: dishes,
        filteredDishes: _applyFilters(
          all: dishes,
          categoryId: categoryId,
          query: query,
        ),
        categories: categories,
        selectedCategoryId: categoryId,
        searchQuery: query,
        scheduledDishIds: scheduledIds,
        userRole: MockHouseholdStore.userRole,
      ));
    } catch (e) {
      emit(DishesManagerError(e.toString()));
    }
  }

  void _onFilter(
    FilterManagerByCategory event,
    Emitter<DishesManagerState> emit,
  ) {
    final current = state;
    if (current is! DishesManagerLoaded) return;

    emit(current.copyWith(
      filteredDishes: _applyFilters(
        all: current.allDishes,
        categoryId: event.categoryId,
        query: current.searchQuery,
      ),
      selectedCategoryId: event.categoryId,
      clearCategory: event.categoryId == null,
      clearActionError: true,
    ));
  }

  void _onSearch(SearchManagerDishes event, Emitter<DishesManagerState> emit) {
    final current = state;
    if (current is! DishesManagerLoaded) return;

    emit(current.copyWith(
      filteredDishes: _applyFilters(
        all: current.allDishes,
        categoryId: current.selectedCategoryId,
        query: event.query,
      ),
      searchQuery: event.query,
      clearActionError: true,
    ));
  }

  Future<void> _onDelete(
    DeleteManagerDish event,
    Emitter<DishesManagerState> emit,
  ) async {
    final current = state;
    if (current is! DishesManagerLoaded || current.deletingDishId != null) return;
    if (!current.isPlanner) return;

    emit(current.copyWith(deletingDishId: event.dishId, clearActionError: true));
    try {
      await _repository.deleteDish(
        householdId: event.householdId,
        dishId: event.dishId,
      );
      final remaining =
          current.allDishes.where((d) => d.id != event.dishId).toList();
      emit(current.copyWith(
        allDishes: remaining,
        filteredDishes: _applyFilters(
          all: remaining,
          categoryId: current.selectedCategoryId,
          query: current.searchQuery,
        ),
        scheduledDishIds:
            current.scheduledDishIds.where((id) => id != event.dishId).toList(),
        clearDeletingDishId: true,
      ));
    } catch (e) {
      emit(current.copyWith(
        clearDeletingDishId: true,
        actionError: 'Could not delete the dish: ${e.toString()}',
      ));
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
