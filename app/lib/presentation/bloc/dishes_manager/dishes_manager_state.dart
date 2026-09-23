import 'package:equatable/equatable.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/dish_model.dart';

abstract class DishesManagerState extends Equatable {
  const DishesManagerState();
  @override
  List<Object?> get props => [];
}

class DishesManagerInitial extends DishesManagerState {}

class DishesManagerLoading extends DishesManagerState {}

class DishesManagerLoaded extends DishesManagerState {
  final List<DishModel> allDishes;
  final List<DishModel> filteredDishes;
  final List<CategoryModel> categories;
  final String? selectedCategoryId;
  final String searchQuery;

  /// Dish IDs booked in the current rolling window (delete warning).
  final List<String> scheduledDishIds;

  /// 'planner' unlocks Add / Edit / Delete; 'member' is read-only.
  final String userRole;

  /// Set while a delete is in flight so the row can show progress.
  final String? deletingDishId;

  final String? actionError;

  const DishesManagerLoaded({
    required this.allDishes,
    required this.filteredDishes,
    required this.categories,
    this.selectedCategoryId,
    this.searchQuery = '',
    required this.scheduledDishIds,
    required this.userRole,
    this.deletingDishId,
    this.actionError,
  });

  bool get isPlanner => userRole == 'planner';

  /// True when the household has no dishes at all (empty-database state).
  bool get isDatabaseEmpty => allDishes.isEmpty;

  DishesManagerLoaded copyWith({
    List<DishModel>? allDishes,
    List<DishModel>? filteredDishes,
    List<CategoryModel>? categories,
    String? selectedCategoryId,
    bool clearCategory = false,
    String? searchQuery,
    List<String>? scheduledDishIds,
    String? userRole,
    String? deletingDishId,
    bool clearDeletingDishId = false,
    String? actionError,
    bool clearActionError = false,
  }) {
    return DishesManagerLoaded(
      allDishes: allDishes ?? this.allDishes,
      filteredDishes: filteredDishes ?? this.filteredDishes,
      categories: categories ?? this.categories,
      selectedCategoryId: clearCategory
          ? null
          : (selectedCategoryId ?? this.selectedCategoryId),
      searchQuery: searchQuery ?? this.searchQuery,
      scheduledDishIds: scheduledDishIds ?? this.scheduledDishIds,
      userRole: userRole ?? this.userRole,
      deletingDishId: clearDeletingDishId
          ? null
          : (deletingDishId ?? this.deletingDishId),
      actionError: clearActionError ? null : (actionError ?? this.actionError),
    );
  }

  @override
  List<Object?> get props => [
    allDishes,
    filteredDishes,
    categories,
    selectedCategoryId,
    searchQuery,
    scheduledDishIds,
    userRole,
    deletingDishId,
    actionError,
  ];
}

class DishesManagerError extends DishesManagerState {
  final String message;
  const DishesManagerError(this.message);
  @override
  List<Object?> get props => [message];
}
