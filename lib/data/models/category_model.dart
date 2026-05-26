import '../../domain/entities/category_entity.dart';

class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.id,
    required super.title,
    required super.description,
    required super.colorValue,
    required super.createdAt,
    required super.updatedAt,
    super.imageUrl,
    super.localImagePath,
  });

  factory CategoryModel.fromEntity(CategoryEntity entity) {
    return CategoryModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      colorValue: entity.colorValue,
      imageUrl: entity.imageUrl,
      localImagePath: entity.localImagePath,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as String,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      colorValue: map['colorValue'] as int? ?? 0xFFA84A1B,
      imageUrl: map['imageUrl'] as String?,
      localImagePath: map['localImagePath'] as String?,
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updatedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'colorValue': colorValue,
      'imageUrl': imageUrl,
      'localImagePath': localImagePath,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
