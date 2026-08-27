import 'package:flutter_test/flutter_test.dart';
import 'package:ghar_ka_menu/data/models/category_model.dart';
import 'package:ghar_ka_menu/data/models/dish_model.dart';
import 'package:ghar_ka_menu/data/repositories/dish_form_repository.dart';
import 'package:ghar_ka_menu/presentation/bloc/dish_form/dish_form_bloc.dart';
import 'package:ghar_ka_menu/presentation/bloc/dish_form/dish_form_event.dart';
import 'package:ghar_ka_menu/presentation/bloc/dish_form/dish_form_state.dart';

const String _householdId = 'h1';

const List<CategoryModel> _categories = [
  CategoryModel(id: 'c1', name: 'Sabzi', sortOrder: 1),
  CategoryModel(id: 'c2', name: 'Daal', sortOrder: 2),
];

const DishModel _existing = DishModel(
  id: 'd1',
  name: 'Bhindi Masala',
  categoryId: 'c1',
  categoryName: 'Sabzi',
  timesCooked: 4,
  ingredientsText: 'Bhindi, Onions',
  notes: 'Do not cover the pan.',
);

class _WriteCall {
  _WriteCall(this.dishId, this.name, this.categoryId, this.ingredientsText, this.notes);

  final String? dishId;
  final String name;
  final String categoryId;
  final String? ingredientsText;
  final String? notes;
}

class _FakeDishFormRepository implements DishFormRepository {
  _FakeDishFormRepository({this.dish, this.writeThrows = false});

  DishModel? dish;
  bool writeThrows;

  final List<_WriteCall> creates = [];
  final List<_WriteCall> updates = [];

  @override
  Future<List<CategoryModel>> fetchCategories(String householdId) async => _categories;

  @override
  Future<DishModel?> fetchDish({
    required String householdId,
    required String dishId,
  }) async =>
      dish;

  @override
  Future<void> createDish({
    required String householdId,
    required String name,
    required String categoryId,
    String? ingredientsText,
    String? notes,
  }) async {
    if (writeThrows) throw Exception('offline');
    creates.add(_WriteCall(null, name, categoryId, ingredientsText, notes));
  }

  @override
  Future<void> updateDish({
    required String householdId,
    required String dishId,
    required String name,
    required String categoryId,
    String? ingredientsText,
    String? notes,
  }) async {
    if (writeThrows) throw Exception('offline');
    updates.add(_WriteCall(dishId, name, categoryId, ingredientsText, notes));
  }
}

/// Loads the bloc and returns it in its [DishFormReady] state.
Future<DishFormBloc> _ready(_FakeDishFormRepository repo, {String? dishId}) async {
  final bloc = DishFormBloc(repository: repo);
  bloc.add(LoadDishForm(householdId: _householdId, dishId: dishId));
  await bloc.stream.firstWhere((s) => s is DishFormReady);
  return bloc;
}

void main() {
  test('Add mode loads an empty form titled "Add New Dish"', () async {
    final bloc = await _ready(_FakeDishFormRepository());
    final state = bloc.state as DishFormReady;

    expect(state.isEditMode, isFalse);
    expect(state.title, 'Add New Dish');
    expect(state.dish, isNull);
    expect(state.categories.length, 2);
    await bloc.close();
  });

  test('Edit mode loads the dish and is titled "Edit Preset Dish"', () async {
    final bloc = await _ready(
      _FakeDishFormRepository(dish: _existing),
      dishId: 'd1',
    );
    final state = bloc.state as DishFormReady;

    expect(state.isEditMode, isTrue);
    expect(state.title, 'Edit Preset Dish');
    expect(state.dish, _existing);
    await bloc.close();
  });

  test('Edit mode on a deleted dish reports "Dish not found"', () async {
    final bloc = DishFormBloc(repository: _FakeDishFormRepository());
    bloc.add(const LoadDishForm(householdId: _householdId, dishId: 'gone'));
    final state = await bloc.stream.firstWhere((s) => s is DishFormError);

    expect((state as DishFormError).message, 'Dish not found');
    await bloc.close();
  });

  test('an empty name is rejected before any write', () async {
    final repo = _FakeDishFormRepository();
    final bloc = await _ready(repo);

    bloc.add(const SubmitDishForm(
      householdId: _householdId,
      name: '   ',
      categoryId: 'c1',
      ingredientsText: '',
      notes: '',
    ));
    final state = await bloc.stream.first as DishFormReady;

    expect(state.nameError, 'Dish name is required');
    expect(state.categoryError, isNull);
    expect(state.isSubmitting, isFalse);
    expect(repo.creates, isEmpty);
    await bloc.close();
  });

  test('a missing category is rejected before any write', () async {
    final repo = _FakeDishFormRepository();
    final bloc = await _ready(repo);

    bloc.add(const SubmitDishForm(
      householdId: _householdId,
      name: 'Aloo Gosht',
      categoryId: null,
      ingredientsText: '',
      notes: '',
    ));
    final state = await bloc.stream.first as DishFormReady;

    expect(state.categoryError, 'Pick a category');
    expect(state.nameError, isNull);
    expect(repo.creates, isEmpty);
    await bloc.close();
  });

  test('both fields blank reports both errors at once', () async {
    final bloc = await _ready(_FakeDishFormRepository());

    bloc.add(const SubmitDishForm(
      householdId: _householdId,
      name: '',
      categoryId: null,
      ingredientsText: '',
      notes: '',
    ));
    final state = await bloc.stream.first as DishFormReady;

    expect(state.nameError, 'Dish name is required');
    expect(state.categoryError, 'Pick a category');
    await bloc.close();
  });

  test('fixing the name clears the earlier error and saves', () async {
    final repo = _FakeDishFormRepository();
    final bloc = await _ready(repo);

    bloc.add(const SubmitDishForm(
      householdId: _householdId,
      name: '',
      categoryId: null,
      ingredientsText: '',
      notes: '',
    ));
    await bloc.stream.first;

    bloc.add(const SubmitDishForm(
      householdId: _householdId,
      name: 'Aloo Gosht',
      categoryId: 'c2',
      ingredientsText: '',
      notes: '',
    ));
    final submitting = await bloc.stream.first as DishFormReady;
    expect(submitting.isSubmitting, isTrue);
    expect(submitting.nameError, isNull);
    expect(submitting.categoryError, isNull);

    expect(await bloc.stream.first, isA<DishFormSaved>());
    expect(repo.creates.length, 1);
    await bloc.close();
  });

  test('Add mode trims the name and stores blank optionals as null', () async {
    final repo = _FakeDishFormRepository();
    final bloc = await _ready(repo);

    bloc.add(const SubmitDishForm(
      householdId: _householdId,
      name: '  Aloo Gosht  ',
      categoryId: 'c2',
      ingredientsText: '   ',
      notes: '',
    ));
    await bloc.stream.firstWhere((s) => s is DishFormSaved);

    expect(repo.updates, isEmpty);
    expect(repo.creates.length, 1);
    final call = repo.creates.single;
    expect(call.name, 'Aloo Gosht');
    expect(call.categoryId, 'c2');
    expect(call.ingredientsText, isNull);
    expect(call.notes, isNull);
    await bloc.close();
  });

  test('Edit mode updates the loaded dish instead of creating one', () async {
    final repo = _FakeDishFormRepository(dish: _existing);
    final bloc = await _ready(repo, dishId: 'd1');

    bloc.add(const SubmitDishForm(
      householdId: _householdId,
      name: 'Bhindi Masala',
      categoryId: 'c2',
      ingredientsText: 'Bhindi, Onions, Tomatoes',
      notes: '  Do not cover the pan.  ',
    ));
    await bloc.stream.firstWhere((s) => s is DishFormSaved);

    expect(repo.creates, isEmpty);
    final call = repo.updates.single;
    expect(call.dishId, 'd1');
    expect(call.categoryId, 'c2');
    expect(call.ingredientsText, 'Bhindi, Onions, Tomatoes');
    expect(call.notes, 'Do not cover the pan.');
    await bloc.close();
  });

  test('a failed save keeps the form open with an error', () async {
    final repo = _FakeDishFormRepository(writeThrows: true);
    final bloc = await _ready(repo);

    bloc.add(const SubmitDishForm(
      householdId: _householdId,
      name: 'Aloo Gosht',
      categoryId: 'c1',
      ingredientsText: '',
      notes: '',
    ));
    await bloc.stream.first; // isSubmitting
    final failed = await bloc.stream.first as DishFormReady;

    expect(failed.isSubmitting, isFalse);
    expect(failed.submitError, contains('Could not save the dish'));
    await bloc.close();
  });
}
