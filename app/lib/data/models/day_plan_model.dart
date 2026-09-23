import 'package:equatable/equatable.dart';
import '../../core/utils/date_format.dart';

enum DayPlanStatus { planned, cooked, cancelled }

class DayPlanModel extends Equatable {
  final String id;
  final DateTime date;
  final String? dishId;
  final String? dishName;
  final String? categoryName;
  final String? dishNotes;
  final DayPlanStatus? status;

  const DayPlanModel({
    required this.id,
    required this.date,
    this.dishId,
    this.dishName,
    this.categoryName,
    this.dishNotes,
    this.status,
  });

  bool get isEmpty => dishId == null;

  /// S7 History row subtitle ("9 July 2026 · Chawal").
  String get historySubtitle {
    final day = formatDayMonthYear(date);
    return categoryName == null ? day : '$day · $categoryName';
  }

  /// S7 History badge discriminator. Only a cancelled day reads "Cancelled";
  /// a past day left as `planned` still counts as served, because at end of day
  /// a planned dish is marked cooked (`docs/BUSINESS_RULES.md`, Day Rollover).
  bool get wasCancelled => status == DayPlanStatus.cancelled;

  @override
  List<Object?> get props => [id, date, dishId, status];

  DayPlanModel copyWith({DayPlanStatus? status}) {
    return DayPlanModel(
      id: id,
      date: date,
      dishId: dishId,
      dishName: dishName,
      categoryName: categoryName,
      dishNotes: dishNotes,
      status: status ?? this.status,
    );
  }

  factory DayPlanModel.fromMap(Map<String, dynamic> map) {
    return DayPlanModel(
      id: map['id'] as String,
      date: DateTime.parse(map['date'] as String),
      dishId: map['dish_id'] as String?,
      dishName: map['dishes']?['name'] as String?,
      categoryName: map['dishes']?['categories']?['name'] as String?,
      dishNotes: map['dishes']?['notes'] as String?,
      status: map['status'] != null
          ? DayPlanStatus.values.byName(map['status'] as String)
          : null,
    );
  }

  factory DayPlanModel.empty({required DateTime date}) {
    return DayPlanModel(
      id: '',
      date: date,
    );
  }
}
