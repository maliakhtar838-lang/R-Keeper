import '../../domain/entities/group_entity.dart';

class GroupModel extends GroupEntity {
  const GroupModel({
    required super.id,
    required super.categoryId,
    required super.title,
    required super.description,
    required super.colorValue,
    required super.createdAt,
    required super.updatedAt,
    super.imageUrl,
    super.localImagePath,
  });

  factory GroupModel.fromEntity(GroupEntity entity) {
    return GroupModel(
      id: entity.id,
      categoryId: entity.categoryId,
      title: entity.title,
      description: entity.description,
      colorValue: entity.colorValue,
      imageUrl: entity.imageUrl,
      localImagePath: entity.localImagePath,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  factory GroupModel.fromMap(Map<String, dynamic> map) {
    return GroupModel(
      id: map['id'] as String,
      categoryId: map['categoryId'] as String,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      colorValue: map['colorValue'] as int? ?? 0xFF7B2E12,
      imageUrl: map['imageUrl'] as String?,
      localImagePath: map['localImagePath'] as String?,
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updatedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'categoryId': categoryId,
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
