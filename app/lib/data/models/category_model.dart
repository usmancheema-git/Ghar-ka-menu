import 'package:equatable/equatable.dart';

class CategoryModel extends Equatable {
  final String id;
  final String name;
  final int sortOrder;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.sortOrder,
  });

  @override
  List<Object?> get props => [id, name];

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as String,
      name: map['name'] as String,
      sortOrder: map['sort_order'] as int? ?? 0,
    );
  }
}
