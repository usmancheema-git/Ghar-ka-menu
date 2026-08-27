import 'package:equatable/equatable.dart';

class DishModel extends Equatable {
  final String id;
  final String name;
  final String categoryId;
  final String categoryName;
  final DateTime? lastCookedOn;
  final int timesCooked;
  final String? ingredientsText;
  final String? notes;

  const DishModel({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.categoryName,
    this.lastCookedOn,
    this.timesCooked = 0,
    this.ingredientsText,
    this.notes,
  });

  /// Recommendation score: days since last cooked.
  /// Dishes never cooked return a very large number (treated as ∞).
  int get score {
    if (lastCookedOn == null) return 99999;
    return DateTime.now().difference(lastCookedOn!).inDays;
  }

  /// Urdu-style label for the days-since display
  String get lastCookedLabel {
    if (lastCookedOn == null) return 'kabhi nahi bani';
    final days = score;
    if (days == 0) return 'aaj hi bani';
    if (days == 1) return '1 din pehle';
    return '$days din pehle';
  }

  /// Stat-box label used on S4 Dish Profile ("12 days ago").
  String get lastCookedStatLabel {
    if (lastCookedOn == null) return 'Never';
    final days = score;
    if (days == 0) return 'Today';
    if (days == 1) return 'Yesterday';
    return '$days days ago';
  }

  /// Stat-box label used on S4 Dish Profile ("8 times").
  String get timesCookedLabel => timesCooked == 1 ? '1 time' : '$timesCooked times';

  /// S5 Dishes Manager row subtitle ("Chawal · Cooked 8×").
  String get managerSubtitle =>
      '$categoryName · ${timesCooked > 0 ? 'Cooked $timesCooked×' : 'Never Cooked'}';

  @override
  List<Object?> get props =>
      [id, name, categoryId, lastCookedOn, timesCooked, ingredientsText, notes];

  factory DishModel.fromMap(Map<String, dynamic> map) {
    return DishModel(
      id: map['id'] as String,
      name: map['name'] as String,
      categoryId: map['category_id'] as String,
      categoryName: map['categories']?['name'] as String? ?? '',
      lastCookedOn: map['last_cooked_on'] != null
          ? DateTime.parse(map['last_cooked_on'] as String)
          : null,
      timesCooked: map['times_cooked'] as int? ?? 0,
      ingredientsText: map['ingredients_text'] as String?,
      notes: map['notes'] as String?,
    );
  }
}
