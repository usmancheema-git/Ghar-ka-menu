import 'package:flutter_test/flutter_test.dart';
import 'package:ghar_ka_menu/data/models/category_model.dart';
import 'package:ghar_ka_menu/data/models/dish_model.dart';
import 'package:ghar_ka_menu/data/repositories/dishes_manager_repository.dart';
import 'package:ghar_ka_menu/presentation/bloc/dishes_manager/dishes_manager_bloc.dart';
import 'package:ghar_ka_menu/presentation/bloc/dishes_manager/dishes_manager_event.dart';
import 'package:ghar_ka_menu/presentation/bloc/dishes_manager/dishes_manager_state.dart';

const String _householdId = 'h1';

const List<CategoryModel> _categories = [
  CategoryModel(id: 'c1', name: 'Sabzi', sortOrder: 1),
  CategoryModel(id: 'c2', name: 'Daal', sortOrder: 2),
];

const List<DishModel> _dishes = [
  DishModel(id: 'd1', name: 'Bhindi Masala', categoryId: 'c1', categoryName: 'Sabzi', timesCooked: 4),
  DishModel(id: 'd2', name: 'Chana Daal', categoryId: 'c2', categoryName: 'Daal', timesCooked: 6),
  DishModel(id: 'd3', name: 'Karelay Pyaz', categoryId: 'c1', categoryName: 'Sabzi'),
];

/// Records calls and lets a test force a failure.
class _FakeDishesManagerRepository implements DishesManagerRepository {
  _FakeDishesManagerRepository({
    this.dishes = _dishes,
    this.deleteThrows = false,
  });

  List<CategoryModel> categories = _categories;
  List<DishModel> dishes;
  List<String> scheduledDishIds = const ['d1'];
  bool deleteThrows;

  final List<String> deletedIds = [];

  @override
  Future<List<CategoryModel>> fetchCategories(String householdId) async => categories;

  @override
  Future<List<DishModel>> fetchDishes(String householdId) async => dishes;

  @override
  Future<List<String>> fetchScheduledDishIds({
    required String householdId,
    required DateTime from,
    required DateTime to,
  }) async =>
      scheduledDishIds;

  @override
  Future<void> deleteDish({
    required String householdId,
    required String dishId,
  }) async {
    if (deleteThrows) throw Exception('offline');
    deletedIds.add(dishId);
  }
}

/// Loads the bloc and returns it in its [DishesManagerLoaded] state.
Future<DishesManagerBloc> _loaded(_FakeDishesManagerRepository repo) async {
  final bloc = DishesManagerBloc(repository: repo);
  bloc.add(const LoadDishesManager(householdId: _householdId));
  await bloc.stream.firstWhere((s) => s is DishesManagerLoaded);
  return bloc;
}

List<String> _names(List<DishModel> dishes) => dishes.map((d) => d.name).toList();

void main() {
  test('load exposes every dish plus the scheduled ids and the planner role', () async {
    final bloc = await _loaded(_FakeDishesManagerRepository());
    final state = bloc.state as DishesManagerLoaded;

    expect(_names(state.allDishes), ['Bhindi Masala', 'Chana Daal', 'Karelay Pyaz']);
    expect(state.filteredDishes, state.allDishes);
    expect(state.categories.length, 2);
    expect(state.selectedCategoryId, isNull);
    expect(state.scheduledDishIds, ['d1']);
    expect(state.isPlanner, isTrue);
    expect(state.isDatabaseEmpty, isFalse);
    await bloc.close();
  });

  test('empty household reports the empty-database state', () async {
    final bloc = await _loaded(_FakeDishesManagerRepository(dishes: const []));
    final state = bloc.state as DishesManagerLoaded;

    expect(state.isDatabaseEmpty, isTrue);
    expect(state.filteredDishes, isEmpty);
    await bloc.close();
  });

  test('load failure emits an error state', () async {
    final bloc = DishesManagerBloc(repository: _ThrowingRepository());
    bloc.add(const LoadDishesManager(householdId: _householdId));
    final state = await bloc.stream.firstWhere((s) => s is DishesManagerError);

    expect((state as DishesManagerError).message, contains('boom'));
    await bloc.close();
  });

  test('category filter keeps only that category, All restores every dish', () async {
    final bloc = await _loaded(_FakeDishesManagerRepository());

    bloc.add(const FilterManagerByCategory('c1'));
    var state = await bloc.stream.first as DishesManagerLoaded;
    expect(_names(state.filteredDishes), ['Bhindi Masala', 'Karelay Pyaz']);
    expect(state.selectedCategoryId, 'c1');

    bloc.add(const FilterManagerByCategory(null));
    state = await bloc.stream.first as DishesManagerLoaded;
    expect(state.filteredDishes.length, 3);
    expect(state.selectedCategoryId, isNull);
    await bloc.close();
  });

  test('search matches on name, case-insensitively', () async {
    final bloc = await _loaded(_FakeDishesManagerRepository());

    bloc.add(const SearchManagerDishes('DAAL'));
    final state = await bloc.stream.first as DishesManagerLoaded;

    expect(_names(state.filteredDishes), ['Chana Daal']);
    expect(state.searchQuery, 'DAAL');
    await bloc.close();
  });

  test('search and category filter combine', () async {
    final bloc = await _loaded(_FakeDishesManagerRepository());

    bloc.add(const FilterManagerByCategory('c1'));
    await bloc.stream.first;
    bloc.add(const SearchManagerDishes('pyaz'));
    final state = await bloc.stream.first as DishesManagerLoaded;

    expect(_names(state.filteredDishes), ['Karelay Pyaz']);
    await bloc.close();
  });

  test('a search with no match leaves the database non-empty', () async {
    final bloc = await _loaded(_FakeDishesManagerRepository());

    bloc.add(const SearchManagerDishes('pizza'));
    final state = await bloc.stream.first as DishesManagerLoaded;

    expect(state.filteredDishes, isEmpty);
    expect(state.isDatabaseEmpty, isFalse); // shows "No dishes found", not "No dishes yet"
    await bloc.close();
  });

  test('reload keeps the active category and search', () async {
    final repo = _FakeDishesManagerRepository();
    final bloc = await _loaded(repo);

    bloc.add(const FilterManagerByCategory('c1'));
    await bloc.stream.first;
    bloc.add(const SearchManagerDishes('bhindi'));
    await bloc.stream.first;

    bloc.add(const LoadDishesManager(householdId: _householdId));
    final state = await bloc.stream.firstWhere((s) => s is DishesManagerLoaded)
        as DishesManagerLoaded;

    expect(state.selectedCategoryId, 'c1');
    expect(state.searchQuery, 'bhindi');
    expect(_names(state.filteredDishes), ['Bhindi Masala']);
    await bloc.close();
  });

  test('reload drops a category that no longer exists', () async {
    final repo = _FakeDishesManagerRepository();
    final bloc = await _loaded(repo);

    bloc.add(const FilterManagerByCategory('c2'));
    await bloc.stream.first;

    repo.categories = const [CategoryModel(id: 'c1', name: 'Sabzi', sortOrder: 1)];
    bloc.add(const LoadDishesManager(householdId: _householdId));
    final state = await bloc.stream.firstWhere((s) => s is DishesManagerLoaded)
        as DishesManagerLoaded;

    expect(state.selectedCategoryId, isNull);
    expect(state.filteredDishes.length, 3);
    await bloc.close();
  });

  test('delete removes the row and clears it from the scheduled ids', () async {
    final repo = _FakeDishesManagerRepository();
    final bloc = await _loaded(repo);

    bloc.add(const DeleteManagerDish(dishId: 'd1', householdId: _householdId));

    final inFlight = await bloc.stream.first as DishesManagerLoaded;
    expect(inFlight.deletingDishId, 'd1');

    final done = await bloc.stream.first as DishesManagerLoaded;
    expect(done.deletingDishId, isNull);
    expect(_names(done.allDishes), ['Chana Daal', 'Karelay Pyaz']);
    expect(_names(done.filteredDishes), ['Chana Daal', 'Karelay Pyaz']);
    expect(done.scheduledDishIds, isEmpty);
    expect(repo.deletedIds, ['d1']);
    await bloc.close();
  });

  test('delete keeps the active filter applied', () async {
    final bloc = await _loaded(_FakeDishesManagerRepository());

    bloc.add(const FilterManagerByCategory('c1'));
    await bloc.stream.first;

    bloc.add(const DeleteManagerDish(dishId: 'd1', householdId: _householdId));
    await bloc.stream.first; // in flight
    final done = await bloc.stream.first as DishesManagerLoaded;

    expect(_names(done.filteredDishes), ['Karelay Pyaz']);
    await bloc.close();
  });

  test('a failed delete surfaces an action error and releases the row', () async {
    final bloc = await _loaded(_FakeDishesManagerRepository(deleteThrows: true));

    bloc.add(const DeleteManagerDish(dishId: 'd1', householdId: _householdId));
    await bloc.stream.first; // in flight
    final failed = await bloc.stream.first as DishesManagerLoaded;

    expect(failed.deletingDishId, isNull);
    expect(failed.actionError, contains('Could not delete the dish'));
    expect(failed.allDishes.length, 3);
    await bloc.close();
  });

  test('filtering clears a stale action error', () async {
    final bloc = await _loaded(_FakeDishesManagerRepository(deleteThrows: true));

    bloc.add(const DeleteManagerDish(dishId: 'd1', householdId: _householdId));
    await bloc.stream.first;
    await bloc.stream.first;

    bloc.add(const FilterManagerByCategory('c1'));
    final state = await bloc.stream.first as DishesManagerLoaded;

    expect(state.actionError, isNull);
    await bloc.close();
  });
}

class _ThrowingRepository implements DishesManagerRepository {
  @override
  Future<List<CategoryModel>> fetchCategories(String householdId) async =>
      throw Exception('boom');

  @override
  Future<List<DishModel>> fetchDishes(String householdId) async => const [];

  @override
  Future<List<String>> fetchScheduledDishIds({
    required String householdId,
    required DateTime from,
    required DateTime to,
  }) async =>
      const [];

  @override
  Future<void> deleteDish({
    required String householdId,
    required String dishId,
  }) async {}
}
