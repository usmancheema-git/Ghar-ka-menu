import 'package:equatable/equatable.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/dish_model.dart';

abstract class DishFormState extends Equatable {
  const DishFormState();
  @override
  List<Object?> get props => [];
}

class DishFormInitial extends DishFormState {}

class DishFormLoading extends DishFormState {}

class DishFormReady extends DishFormState {
  final List<CategoryModel> categories;

  /// Existing row in Edit mode; null in Add mode.
  final DishModel? dish;

  final bool isSubmitting;
  final String? nameError;
  final String? categoryError;
  final String? submitError;

  const DishFormReady({
    required this.categories,
    this.dish,
    this.isSubmitting = false,
    this.nameError,
    this.categoryError,
    this.submitError,
  });

  bool get isEditMode => dish != null;

  /// `.header-back-title` — "Add New Dish" / "Edit Preset Dish".
  String get title => isEditMode ? 'Edit Preset Dish' : 'Add New Dish';

  DishFormReady copyWith({
    List<CategoryModel>? categories,
    DishModel? dish,
    bool? isSubmitting,
    String? nameError,
    String? categoryError,
    String? submitError,
    bool clearErrors = false,
  }) {
    return DishFormReady(
      categories: categories ?? this.categories,
      dish: dish ?? this.dish,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      nameError: clearErrors ? null : (nameError ?? this.nameError),
      categoryError: clearErrors ? null : (categoryError ?? this.categoryError),
      submitError: clearErrors ? null : (submitError ?? this.submitError),
    );
  }

  @override
  List<Object?> get props =>
      [categories, dish, isSubmitting, nameError, categoryError, submitError];
}

/// Saved successfully — S6 pops back to S5.
class DishFormSaved extends DishFormState {}

class DishFormError extends DishFormState {
  final String message;
  const DishFormError(this.message);
  @override
  List<Object?> get props => [message];
}
