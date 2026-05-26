class CategoryEntity {
  const CategoryEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.colorValue,
    required this.createdAt,
    required this.updatedAt,
    this.imageUrl,
    this.localImagePath,
  });

  final String id;
  final String title;
  final String description;
  final int colorValue;
  final String? imageUrl;
  final String? localImagePath;
  final DateTime createdAt;
  final DateTime updatedAt;

  CategoryEntity copyWith({
    String? id,
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
    return CategoryEntity(
      id: id ?? this.id,
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
