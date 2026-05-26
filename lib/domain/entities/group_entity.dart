class GroupEntity {
  const GroupEntity({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.description,
    required this.colorValue,
    required this.createdAt,
    required this.updatedAt,
    this.imageUrl,
    this.localImagePath,
  });

  final String id;
  final String categoryId;
  final String title;
  final String description;
  final int colorValue;
  final String? imageUrl;
  final String? localImagePath;
  final DateTime createdAt;
  final DateTime updatedAt;

  GroupEntity copyWith({
    String? id,
    String? categoryId,
    String? title,
    String? description,
    int? colorValue,
    String? imageUrl,
    String? localImagePath,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearImageUrl = false,
    bool clearLocalImagePath = false,
  }) {
    return GroupEntity(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,
      description: description ?? this.description,
      colorValue: colorValue ?? this.colorValue,
      imageUrl: clearImageUrl ? null : imageUrl ?? this.imageUrl,
      localImagePath: clearLocalImagePath ? null : localImagePath ?? this.localImagePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
