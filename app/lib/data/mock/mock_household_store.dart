import '../models/category_model.dart';
import '../models/day_plan_model.dart';
import '../models/dish_model.dart';

/// In-memory household data used while Supabase is not wired.
/// Shared by Week View and Assign Dish so assigning a dish updates S2.
class MockHouseholdStore {
  MockHouseholdStore._() {
    _seed();
  }

  static final MockHouseholdStore instance = MockHouseholdStore._();

  static const String householdId = 'household-mock-id';
  static const String householdName = 'Awais Family';

  /// Signed-in member's role. Comes from `members.role` once auth is wired.
  static const String userRole = 'planner';

  final List<CategoryModel> categories = const [
    CategoryModel(id: 'c1', name: 'Sabzi', sortOrder: 1),
    CategoryModel(id: 'c2', name: 'Daal', sortOrder: 2),
    CategoryModel(id: 'c3', name: 'Chawal', sortOrder: 3),
    CategoryModel(id: 'c4', name: 'Gosht', sortOrder: 4),
    CategoryModel(id: 'c5', name: 'Murgh', sortOrder: 5),
    CategoryModel(id: 'c6', name: 'Special', sortOrder: 6),
  ];

  late final List<DishModel> dishes;
  final Map<String, DayPlanModel> _plansByDate = {};

  DateTime get today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  String dateKey(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
  }

  List<DishModel> dishesSortedByScore() {
    final sorted = List<DishModel>.from(dishes);
    sorted.sort((a, b) => b.score.compareTo(a.score));
    return sorted;
  }

  /// Alphabetical order for the S5 database listing.
  List<DishModel> dishesSortedByName() {
    final sorted = List<DishModel>.from(dishes);
    sorted.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return sorted;
  }

  DishModel? dishById(String id) {
    for (final dish in dishes) {
      if (dish.id == id) return dish;
    }
    return null;
  }

  CategoryModel? categoryById(String id) {
    for (final category in categories) {
      if (category.id == id) return category;
    }
    return null;
  }

  /// Dish IDs already present in [from]..[to] day_plans (repeat warning).
  List<String> plannedDishIds(DateTime from, DateTime to) {
    final ids = <String>{};
    for (int i = 0; i <= to.difference(from).inDays; i++) {
      final plan = _plansByDate[dateKey(from.add(Duration(days: i)))];
      if (plan?.dishId != null) ids.add(plan!.dishId!);
    }
    return ids.toList();
  }

  List<DayPlanModel> weekPlans(DateTime from, DateTime to) {
    final result = <DayPlanModel>[];
    final days = to.difference(from).inDays;
    for (int i = 0; i <= days; i++) {
      final day = from.add(Duration(days: i));
      result.add(_plansByDate[dateKey(day)] ?? DayPlanModel.empty(date: day));
    }
    return result;
  }

  void upsertDayPlan({
    required String dishId,
    required DateTime date,
  }) {
    final dish = dishById(dishId);
    if (dish == null) {
      throw StateError('Dish not found');
    }
    final key = dateKey(date);
    final existing = _plansByDate[key];
    _plansByDate[key] = DayPlanModel(
      id: (existing != null && existing.id.isNotEmpty) ? existing.id : 'plan-$key',
      date: DateTime(date.year, date.month, date.day),
      dishId: dish.id,
      dishName: dish.name,
      categoryName: dish.categoryName,
      dishNotes: dish.notes,
      status: DayPlanStatus.planned,
    );
  }

  void updatePlanStatus(String planId, DayPlanStatus status) {
    for (final entry in _plansByDate.entries) {
      if (entry.value.id == planId) {
        _plansByDate[entry.key] = entry.value.copyWith(status: status);
        return;
      }
    }
  }

  // ─── Dish CRUD (S5 Dishes Manager / S6 Add-Edit Dish) ──────────────────────

  int _nextDishSeq = 1;

  DishModel addDish({
    required String name,
    required String categoryId,
    String? ingredientsText,
    String? notes,
  }) {
    final category = categoryById(categoryId);
    if (category == null) {
      throw StateError('Category not found');
    }
    final dish = DishModel(
      id: 'd-new-${_nextDishSeq++}',
      name: name,
      categoryId: categoryId,
      categoryName: category.name,
      ingredientsText: ingredientsText,
      notes: notes,
    );
    dishes.add(dish);
    return dish;
  }

  DishModel updateDish({
    required String id,
    required String name,
    required String categoryId,
    String? ingredientsText,
    String? notes,
  }) {
    final index = dishes.indexWhere((d) => d.id == id);
    if (index == -1) {
      throw StateError('Dish not found');
    }
    final category = categoryById(categoryId);
    if (category == null) {
      throw StateError('Category not found');
    }
    final existing = dishes[index];
    final updated = DishModel(
      id: existing.id,
      name: name,
      categoryId: categoryId,
      categoryName: category.name,
      lastCookedOn: existing.lastCookedOn,
      timesCooked: existing.timesCooked,
      ingredientsText: ingredientsText,
      notes: notes,
    );
    dishes[index] = updated;
    _refreshPlansForDish(updated);
    return updated;
  }

  /// Deletes the dish and clears it from any day_plans that referenced it,
  /// leaving those days unassigned (S5 spec: cascades/nullifies `day_plans`).
  void deleteDish(String id) {
    final index = dishes.indexWhere((d) => d.id == id);
    if (index == -1) {
      throw StateError('Dish not found');
    }
    dishes.removeAt(index);
    for (final entry in _plansByDate.entries.toList()) {
      if (entry.value.dishId == id) {
        _plansByDate[entry.key] = DayPlanModel.empty(date: entry.value.date);
      }
    }
  }

  /// Keeps the denormalised dish fields on existing day_plans in sync after an
  /// edit (Supabase resolves these through a join instead).
  void _refreshPlansForDish(DishModel dish) {
    for (final entry in _plansByDate.entries.toList()) {
      final plan = entry.value;
      if (plan.dishId != dish.id) continue;
      _plansByDate[entry.key] = DayPlanModel(
        id: plan.id,
        date: plan.date,
        dishId: dish.id,
        dishName: dish.name,
        categoryName: dish.categoryName,
        dishNotes: dish.notes,
        status: plan.status,
      );
    }
  }

  void _seed() {
    final now = today;
    dishes = [
      // d1 intentionally has no ingredients/notes — exercises the S4 empty state.
      DishModel(
        id: 'd1',
        name: 'Karelay Pyaz',
        categoryId: 'c1',
        categoryName: 'Sabzi',
        timesCooked: 0,
      ),
      DishModel(
        id: 'd2',
        name: 'Haleem Special',
        categoryId: 'c6',
        categoryName: 'Special',
        lastCookedOn: now.subtract(const Duration(days: 25)),
        timesCooked: 3,
        ingredientsText:
            'Beef (1 kg), Wheat, Barley, Chana Daal, Masoor Daal, Fried Onions, '
            'Ginger, Garam Masala, Fresh Coriander, Lemon.',
      ),
      DishModel(
        id: 'd3',
        name: 'Chicken Pulao',
        categoryId: 'c3',
        categoryName: 'Chawal',
        lastCookedOn: now.subtract(const Duration(days: 18)),
        timesCooked: 7,
        ingredientsText:
            'Chicken (1 kg), Basmati Rice (750 g), Onions, Whole Spices, '
            'Ginger & Garlic paste, Green Chillies, Yogurt.',
      ),
      DishModel(
        id: 'd4',
        name: 'Daal Mash (Fry)',
        categoryId: 'c2',
        categoryName: 'Daal',
        lastCookedOn: now.subtract(const Duration(days: 12)),
        timesCooked: 10,
        ingredientsText:
            'Mash Daal (500 g), Onions, Tomatoes, Ginger, Green Chillies, '
            'Cumin, Fresh Coriander.',
      ),
      DishModel(
        id: 'd5',
        name: 'Chicken Biryani',
        categoryId: 'c3',
        categoryName: 'Chawal',
        lastCookedOn: now.subtract(const Duration(days: 1)),
        timesCooked: 15,
        ingredientsText:
            'Chicken (1 kg), Basmati Rice (750 g), Yogurt, Fried Onions, '
            'Biryani Masala, Fresh Mint, Coriander, Green Chillies, Tomatoes, '
            'Garlic & Ginger paste.',
        notes: 'Marinate chicken 2 hrs early.',
      ),
      DishModel(
        id: 'd6',
        name: 'Bhindi Masala',
        categoryId: 'c1',
        categoryName: 'Sabzi',
        lastCookedOn: now,
        timesCooked: 20,
        ingredientsText:
            'Bhindi (750 g), Onions, Tomatoes, Green Chillies, Haldi, '
            'Red Chilli powder, Coriander powder.',
        notes: "Don't cover the pan while cooking.",
      ),
      DishModel(
        id: 'd7',
        name: 'Aloo Qeema',
        categoryId: 'c4',
        categoryName: 'Gosht',
        lastCookedOn: now.subtract(const Duration(days: 5)),
        timesCooked: 8,
        ingredientsText:
            'Beef Qeema (500 g), Potatoes (3 medium), Onions, Tomatoes, '
            'Ginger & Garlic paste, Garam Masala, Fresh Coriander.',
      ),
      DishModel(
        id: 'd8',
        name: 'Chicken Karahi',
        categoryId: 'c5',
        categoryName: 'Murgh',
        lastCookedOn: now.subtract(const Duration(days: 4)),
        timesCooked: 12,
        ingredientsText:
            'Chicken (1 kg), Tomatoes (500 g), Green Chillies, Ginger julienne, '
            'Black Pepper, Kasuri Methi, Butter.',
        notes: 'Skipped — guests came.',
      ),
      DishModel(
        id: 'd9',
        name: 'Saag Gosht',
        categoryId: 'c4',
        categoryName: 'Gosht',
        lastCookedOn: now.subtract(const Duration(days: 9)),
        timesCooked: 5,
        ingredientsText:
            'Mutton (750 g), Sarson ka Saag, Palak, Makhan, Garlic, '
            'Green Chillies, Ginger.',
      ),
      DishModel(
        id: 'd10',
        name: 'Chana Daal',
        categoryId: 'c2',
        categoryName: 'Daal',
        lastCookedOn: now.subtract(const Duration(days: 7)),
        timesCooked: 6,
        ingredientsText:
            'Chana Daal (500 g), Onions, Tomatoes, Haldi, Zeera, '
            'Ginger & Garlic paste, Fresh Coriander.',
      ),
    ];

    void put(int offset, String dishId, DayPlanStatus status) {
      final date = now.add(Duration(days: offset));
      final dish = dishById(dishId)!;
      final key = dateKey(date);
      _plansByDate[key] = DayPlanModel(
        id: 'plan-$key',
        date: date,
        dishId: dish.id,
        dishName: dish.name,
        categoryName: dish.categoryName,
        dishNotes: dish.notes,
        status: status,
      );
    }

    put(0, 'd6', DayPlanStatus.cooked);
    put(1, 'd5', DayPlanStatus.planned);
    put(3, 'd4', DayPlanStatus.planned);
    put(4, 'd8', DayPlanStatus.cancelled);
    put(6, 'd7', DayPlanStatus.planned);
  }
}
