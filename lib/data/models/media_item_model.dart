import '../../domain/entities/media_item_entity.dart';

class MediaItemModel extends MediaItemEntity {
  const MediaItemModel({
    required super.id,
    required super.categoryId,
    required super.title,
    required super.description,
    required super.progressLabel,
    required super.currentProgress,
    required super.sourceUrl,
    required super.status,
    required super.colorValue,
    required super.createdAt,
    required super.updatedAt,
    super.groupId,
    super.coverImageUrl,
    super.localImagePath,
  });

  factory MediaItemModel.fromEntity(MediaItemEntity entity) {
    return MediaItemModel(
      id: entity.id,
      categoryId: entity.categoryId,
      groupId: entity.groupId,
      title: entity.title,
      description: entity.description,
      progressLabel: entity.progressLabel,
      currentProgress: entity.currentProgress,
      sourceUrl: entity.sourceUrl,
      status: entity.status,
      colorValue: entity.colorValue,
      coverImageUrl: entity.coverImageUrl,
      localImagePath: entity.localImagePath,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  factory MediaItemModel.fromMap(Map<String, dynamic> map) {
    return MediaItemModel(
      id: map['id'] as String,
      categoryId: map['categoryId'] as String,
      groupId: map['groupId'] as String?,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      progressLabel: map['progressLabel'] as String? ?? 'Ch',
      currentProgress: map['currentProgress'] as int? ?? 0,
      sourceUrl: map['sourceUrl'] as String? ?? '',
      status: MediaStatusLabel.fromName(map['status'] as String? ?? MediaStatus.reading.name),
      colorValue: map['colorValue'] as int? ?? 0xFFA84A1B,
      coverImageUrl: map['coverImageUrl'] as String?,
      localImagePath: map['localImagePath'] as String?,
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updatedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'categoryId': categoryId,
      'groupId': groupId,
      'title': title,
      'description': description,
      'progressLabel': progressLabel,
      'currentProgress': currentProgress,
      'sourceUrl': sourceUrl,
      'status': status.name,
      'colorValue': colorValue,
      'coverImageUrl': coverImageUrl,
      'localImagePath': localImagePath,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
