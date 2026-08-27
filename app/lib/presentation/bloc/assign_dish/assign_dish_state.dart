import 'package:equatable/equatable.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/dish_model.dart';

abstract class AssignDishState extends Equatable {
  const AssignDishState();
  @override
  List<Object?> get props => [];
}

class AssignDishInitial extends AssignDishState {}

class AssignDishLoading extends AssignDishState {}

class AssignDishLoaded extends AssignDishState {
  final List<DishModel> allDishes;
  final List<DishModel> filteredDishes;
  final List<CategoryModel> categories;
  final String? selectedCategoryId;
  final String searchQuery;
  final List<String> alreadyPlannedDishIds;
  final bool isAssigning;
  final String? actionError;

  const AssignDishLoaded({
    required this.allDishes,
    required this.filteredDishes,
    required this.categories,
    this.selectedCategoryId,
    this.searchQuery = '',
    required this.alreadyPlannedDishIds,
    this.isAssigning = false,
    this.actionError,
  });

  AssignDishLoaded copyWith({
    List<DishModel>? allDishes,
    List<DishModel>? filteredDishes,
    List<CategoryModel>? categories,
    String? selectedCategoryId,
    bool clearCategory = false,
    String? searchQuery,
    List<String>? alreadyPlannedDishIds,
    bool? isAssigning,
    String? actionError,
    bool clearActionError = false,
  }) {
    return AssignDishLoaded(
      allDishes: allDishes ?? this.allDishes,
      filteredDishes: filteredDishes ?? this.filteredDishes,
      categories: categories ?? this.categories,
      selectedCategoryId:
          clearCategory ? null : (selectedCategoryId ?? this.selectedCategoryId),
      searchQuery: searchQuery ?? this.searchQuery,
      alreadyPlannedDishIds: alreadyPlannedDishIds ?? this.alreadyPlannedDishIds,
      isAssigning: isAssigning ?? this.isAssigning,
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
        alreadyPlannedDishIds,
        isAssigning,
        actionError,
      ];
}

class AssignDishSuccess extends AssignDishState {}

class AssignDishError extends AssignDishState {
  final String message;
  const AssignDishError(this.message);
  @override
  List<Object?> get props => [message];
}
