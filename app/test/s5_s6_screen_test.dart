import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ghar_ka_menu/core/theme/app_theme.dart';
import 'package:ghar_ka_menu/data/models/category_model.dart';
import 'package:ghar_ka_menu/data/models/dish_model.dart';
import 'package:ghar_ka_menu/data/repositories/dish_form_repository.dart';
import 'package:ghar_ka_menu/data/repositories/dishes_manager_repository.dart';
import 'package:ghar_ka_menu/presentation/screens/s5_dishes_manager/s5_dishes_manager_screen.dart';
import 'package:ghar_ka_menu/presentation/screens/s6_add_edit_dish/s6_add_edit_dish_screen.dart';

/// Covers the seam the bloc tests cannot see: which control dispatches what,
/// what the planner reads on screen, and that saving in S6 refreshes S5.

const List<CategoryModel> _categories = [
  CategoryModel(id: 'c1', name: 'Sabzi', sortOrder: 1),
  CategoryModel(id: 'c2', name: 'Daal', sortOrder: 2),
];

String _categoryName(String id) =>
    _categories.firstWhere((c) => c.id == id).name;

/// Stands in for the household's rows, shared by both fake repositories so a
/// write through S6 is visible to S5.
class _Db {
  List<DishModel> dishes = const [
    DishModel(
      id: 'd1',
      name: 'Bhindi Masala',
      categoryId: 'c1',
      categoryName: 'Sabzi',
      timesCooked: 4,
      ingredientsText: 'Bhindi, Onions',
      notes: 'Do not cover the pan.',
    ),
    DishModel(
      id: 'd2',
      name: 'Chana Daal',
      categoryId: 'c2',
      categoryName: 'Daal',
    ),
  ];

  /// 'd1' is on the current week plan; 'd2' is not.
  List<String> scheduled = ['d1'];

  DishModel? byId(String id) =>
      dishes.where((d) => d.id == id).firstOrNull;
}

class _FakeManagerRepository implements DishesManagerRepository {
  _FakeManagerRepository(this.db);

  final _Db db;
  final List<String> deletedIds = [];

  @override
  Future<List<CategoryModel>> fetchCategories(String householdId) async =>
      _categories;

  @override
  Future<List<DishModel>> fetchDishes(String householdId) async => db.dishes;

  @override
  Future<List<String>> fetchScheduledDishIds({
    required String householdId,
    required DateTime from,
    required DateTime to,
  }) async =>
      db.scheduled;

  @override
  Future<void> deleteDish({
    required String householdId,
    required String dishId,
  }) async {
    deletedIds.add(dishId);
    db.dishes = db.dishes.where((d) => d.id != dishId).toList();
    db.scheduled = db.scheduled.where((id) => id != dishId).toList();
  }
}

class _FakeFormRepository implements DishFormRepository {
  _FakeFormRepository(this.db);

  final _Db db;
  final List<Map<String, Object?>> creates = [];
  final List<Map<String, Object?>> updates = [];

  @override
  Future<List<CategoryModel>> fetchCategories(String householdId) async =>
      _categories;

  @override
  Future<DishModel?> fetchDish({
    required String householdId,
    required String dishId,
  }) async =>
      db.byId(dishId);

  @override
  Future<void> createDish({
    required String householdId,
    required String name,
    required String categoryId,
    String? ingredientsText,
    String? notes,
  }) async {
    creates.add({
      'name': name,
      'categoryId': categoryId,
      'ingredientsText': ingredientsText,
      'notes': notes,
    });
    db.dishes = [
      ...db.dishes,
      DishModel(
        id: 'new${db.dishes.length + 1}',
        name: name,
        categoryId: categoryId,
        categoryName: _categoryName(categoryId),
        ingredientsText: ingredientsText,
        notes: notes,
      ),
    ];
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
    updates.add({
      'dishId': dishId,
      'name': name,
      'categoryId': categoryId,
      'ingredientsText': ingredientsText,
      'notes': notes,
    });
    db.dishes = db.dishes.map((d) {
      if (d.id != dishId) return d;
      return DishModel(
        id: d.id,
        name: name,
        categoryId: categoryId,
        categoryName: _categoryName(categoryId),
        lastCookedOn: d.lastCookedOn,
        timesCooked: d.timesCooked,
        ingredientsText: ingredientsText,
        notes: notes,
      );
    }).toList();
  }
}

/// The routes S5 and S6 navigate between, plus stubs for the rest.
Widget _app(String initialLocation) {
  final router = GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(path: '/dishes', builder: (_, _) => const S5DishesManagerScreen()),
      GoRoute(
        path: '/dishes/new',
        builder: (_, _) => const S6AddEditDishScreen(),
      ),
      GoRoute(
        path: '/dishes/edit/:id',
        builder: (_, state) =>
            S6AddEditDishScreen(dishId: state.pathParameters['id']),
      ),
      GoRoute(path: '/dish/:id', builder: (_, _) => const _Stub('S4')),
      GoRoute(path: '/home', builder: (_, _) => const _Stub('S2')),
      GoRoute(path: '/history', builder: (_, _) => const _Stub('S7')),
      GoRoute(path: '/settings', builder: (_, _) => const _Stub('S8')),
    ],
  );
  return MaterialApp.router(theme: AppTheme.lightTheme, routerConfig: router);
}

class _Stub extends StatelessWidget {
  const _Stub(this.label);

  final String label;

  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: Text(label)));
}

Finder _icon(FaIconData icon) => find.byIcon(icon.data);

/// Row order matches the fetched list: 0 is Bhindi Masala, 1 is Chana Daal.
Finder _deleteIcon(int row) => _icon(FontAwesomeIcons.trashCan).at(row);

Finder _editIcon(int row) => _icon(FontAwesomeIcons.penToSquare).at(row);

void main() {
  final getIt = GetIt.instance;
  late _Db db;
  late _FakeManagerRepository managerRepo;
  late _FakeFormRepository formRepo;

  setUpAll(() {
    // Keeps the tests off the network; the bundled fallback font is used.
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    db = _Db();
    managerRepo = _FakeManagerRepository(db);
    formRepo = _FakeFormRepository(db);
    getIt.registerFactory<DishesManagerRepository>(() => managerRepo);
    getIt.registerFactory<DishFormRepository>(() => formRepo);
  });

  tearDown(() => getIt.reset());

  group('S5 Dishes Manager', () {
    testWidgets('lists every preset with its category and cook count',
        (tester) async {
      await tester.pumpWidget(_app('/dishes'));
      await tester.pumpAndSettle();

      expect(find.text('Dishes Database'), findsOneWidget);
      expect(find.text('2 household presets'), findsOneWidget);
      expect(find.text('Bhindi Masala'), findsOneWidget);
      expect(find.text('Sabzi · Cooked 4×'), findsOneWidget);
      expect(find.text('Chana Daal'), findsOneWidget);
      expect(find.text('Daal · Never Cooked'), findsOneWidget);
    });

    testWidgets('typing in the search box narrows the list', (tester) async {
      await tester.pumpWidget(_app('/dishes'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'chana');
      await tester.pumpAndSettle();

      expect(find.text('Chana Daal'), findsOneWidget);
      expect(find.text('Bhindi Masala'), findsNothing);
    });

    testWidgets('a search with no match shows the no-results copy',
        (tester) async {
      await tester.pumpWidget(_app('/dishes'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'pizza');
      await tester.pumpAndSettle();

      expect(find.text('No dishes found'), findsOneWidget);
      expect(
        find.text('Try a different category or search term'),
        findsOneWidget,
      );
      expect(find.text('No dishes yet'), findsNothing);
    });

    testWidgets('tapping a category tab filters, All restores', (tester) async {
      await tester.pumpWidget(_app('/dishes'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Daal'));
      await tester.pumpAndSettle();
      expect(find.text('Chana Daal'), findsOneWidget);
      expect(find.text('Bhindi Masala'), findsNothing);

      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();
      expect(find.text('Bhindi Masala'), findsOneWidget);
    });

    testWidgets('an empty database invites the planner to add the first dish',
        (tester) async {
      db.dishes = const [];
      await tester.pumpWidget(_app('/dishes'));
      await tester.pumpAndSettle();

      expect(find.text('No dishes yet'), findsOneWidget);
      expect(find.text('Tap + to add your first dish preset.'), findsOneWidget);
    });

    testWidgets('deleting a scheduled dish warns about the week plan',
        (tester) async {
      await tester.pumpWidget(_app('/dishes'));
      await tester.pumpAndSettle();

      await tester.tap(_deleteIcon(0), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.text('Delete this dish?'), findsOneWidget);
      expect(
        find.text(
          'Bhindi Masala is planned in this week. Deleting it will leave that '
          'day unassigned.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('deleting an unscheduled dish gets the plain copy',
        (tester) async {
      await tester.pumpWidget(_app('/dishes'));
      await tester.pumpAndSettle();

      await tester.tap(_deleteIcon(1), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(
        find.text('Chana Daal will be removed from the dishes database.'),
        findsOneWidget,
      );
    });

    testWidgets('cancelling the dialog keeps the dish', (tester) async {
      await tester.pumpWidget(_app('/dishes'));
      await tester.pumpAndSettle();

      await tester.tap(_deleteIcon(0), warnIfMissed: false);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(managerRepo.deletedIds, isEmpty);
      expect(find.text('Bhindi Masala'), findsOneWidget);
    });

    testWidgets('confirming the dialog deletes the dish and drops the row',
        (tester) async {
      await tester.pumpWidget(_app('/dishes'));
      await tester.pumpAndSettle();

      await tester.tap(_deleteIcon(0), warnIfMissed: false);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(managerRepo.deletedIds, ['d1']);
      expect(find.text('Bhindi Masala'), findsNothing);
      expect(find.text('Chana Daal'), findsOneWidget);
    });

    testWidgets('tapping a row opens that dish profile', (tester) async {
      await tester.pumpWidget(_app('/dishes'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Chana Daal'));
      await tester.pumpAndSettle();

      expect(find.text('S4'), findsOneWidget);
    });

    testWidgets('the row pencil opens the form on that dish', (tester) async {
      await tester.pumpWidget(_app('/dishes'));
      await tester.pumpAndSettle();

      await tester.tap(_editIcon(1), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.text('Edit Preset Dish'), findsOneWidget);
      expect(find.text('Chana Daal'), findsOneWidget);
    });

    testWidgets('the + button opens an empty add form', (tester) async {
      await tester.pumpWidget(_app('/dishes'));
      await tester.pumpAndSettle();

      await tester.tap(_icon(FontAwesomeIcons.plus), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.text('Add New Dish'), findsOneWidget);
      expect(find.text('Select a category'), findsOneWidget);
    });

    testWidgets('the bottom nav reaches the other tabs', (tester) async {
      await tester.pumpWidget(_app('/dishes'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Week Plan'));
      await tester.pumpAndSettle();

      expect(find.text('S2'), findsOneWidget);
    });
  });

  group('S6 Add / Edit Dish', () {
    testWidgets('saving an empty form reports both missing fields',
        (tester) async {
      await tester.pumpWidget(_app('/dishes/new'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save Dish Preset'));
      await tester.pumpAndSettle();

      expect(find.text('Dish name is required'), findsOneWidget);
      expect(find.text('Pick a category'), findsOneWidget);
      expect(formRepo.creates, isEmpty);
    });

    testWidgets('a filled form creates the dish and refreshes the list',
        (tester) async {
      await tester.pumpWidget(_app('/dishes'));
      await tester.pumpAndSettle();

      await tester.tap(_icon(FontAwesomeIcons.plus), warnIfMissed: false);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).at(0), '  Aloo Gosht  ');
      await tester.enterText(find.byType(TextField).at(1), 'Mutton, Potatoes');
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Daal').last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save Dish Preset'));
      await tester.pumpAndSettle();

      expect(formRepo.creates.single, {
        'name': 'Aloo Gosht',
        'categoryId': 'c2',
        'ingredientsText': 'Mutton, Potatoes',
        'notes': null,
      });
      // Popped back to S5, which reloaded and now shows the new preset.
      expect(find.text('Dishes Database'), findsOneWidget);
      expect(find.text('3 household presets'), findsOneWidget);
      expect(find.text('Aloo Gosht'), findsOneWidget);
    });

    testWidgets('edit mode pre-fills the dish and updates it', (tester) async {
      await tester.pumpWidget(_app('/dishes/edit/d1'));
      await tester.pumpAndSettle();

      expect(find.text('Edit Preset Dish'), findsOneWidget);
      expect(find.text('Bhindi Masala'), findsOneWidget);
      expect(find.text('Sabzi'), findsOneWidget);
      expect(find.text('Bhindi, Onions'), findsOneWidget);
      expect(find.text('Do not cover the pan.'), findsOneWidget);

      await tester.enterText(find.byType(TextField).at(0), 'Bhindi Fry');
      await tester.tap(find.text('Save Dish Preset'));
      await tester.pumpAndSettle();

      expect(formRepo.creates, isEmpty);
      expect(formRepo.updates.single, {
        'dishId': 'd1',
        'name': 'Bhindi Fry',
        'categoryId': 'c1',
        'ingredientsText': 'Bhindi, Onions',
        'notes': 'Do not cover the pan.',
      });
    });

    testWidgets('an edit made from S5 shows up in the list', (tester) async {
      await tester.pumpWidget(_app('/dishes'));
      await tester.pumpAndSettle();

      await tester.tap(_editIcon(0), warnIfMissed: false);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).at(0), 'Bhindi Fry');
      await tester.tap(find.text('Save Dish Preset'));
      await tester.pumpAndSettle();

      expect(find.text('Dishes Database'), findsOneWidget);
      expect(find.text('Bhindi Fry'), findsOneWidget);
      expect(find.text('Bhindi Masala'), findsNothing);
      // The cook count survives the edit.
      expect(find.text('Sabzi · Cooked 4×'), findsOneWidget);
    });

    testWidgets('clearing an optional field stores null', (tester) async {      await tester.pumpWidget(_app('/dishes/edit/d1'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).at(2), '   ');
      await tester.tap(find.text('Save Dish Preset'));
      await tester.pumpAndSettle();

      expect(formRepo.updates.single['notes'], isNull);
    });

    testWidgets('edit mode on a deleted dish shows the not-found state',
        (tester) async {
      await tester.pumpWidget(_app('/dishes/edit/gone'));
      await tester.pumpAndSettle();

      expect(find.text('Dish not found'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('the back button returns to the list without saving',
        (tester) async {
      await tester.pumpWidget(_app('/dishes'));
      await tester.pumpAndSettle();

      await tester.tap(_icon(FontAwesomeIcons.plus), warnIfMissed: false);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).at(0), 'Aloo Gosht');
      await tester.tap(_icon(FontAwesomeIcons.arrowLeft), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.text('Dishes Database'), findsOneWidget);
      expect(find.text('2 household presets'), findsOneWidget);
      expect(formRepo.creates, isEmpty);
    });
  });
}
