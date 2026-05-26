enum MediaStatus { reading, watching, onHold, dropped, completed, planToWatch }

extension MediaStatusLabel on MediaStatus {
  String get label {
    switch (this) {
      case MediaStatus.reading:
        return 'Reading';
      case MediaStatus.watching:
        return 'Watching';
      case MediaStatus.onHold:
        return 'On Hold';
      case MediaStatus.dropped:
        return 'Dropped';
      case MediaStatus.completed:
        return 'Completed';
      case MediaStatus.planToWatch:
        return 'Plan to Watch';
    }
  }

  static MediaStatus fromName(String value) {
    return MediaStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => MediaStatus.reading,
    );
  }
}

class MediaItemEntity {
  const MediaItemEntity({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.description,
    required this.progressLabel,
    required this.currentProgress,
    required this.sourceUrl,
    required this.status,
    required this.colorValue,
    required this.createdAt,
    required this.updatedAt,
    this.groupId,
    this.coverImageUrl,
    this.localImagePath,
  });

  final String id;
  final String categoryId;
  final String? groupId;
  final String title;
  final String description;
  final String progressLabel;
  final int currentProgress;
  final String sourceUrl;
  final MediaStatus status;
  final int colorValue;
  final String? coverImageUrl;
  final String? localImagePath;
  final DateTime createdAt;
  final DateTime updatedAt;

  MediaItemEntity copyWith({
    String? id,
    String? categoryId,
    String? groupId,
    String? title,
    String? description,
    String? progressLabel,
    int? currentProgress,
    String? sourceUrl,
    MediaStatus? status,
    int? colorValue,
    String? coverImageUrl,
    String? localImagePath,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearGroup = false,
    bool clearCoverImageUrl = false,
    bool clearLocalImagePath = false,
  }) {
    return MediaItemEntity(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      groupId: clearGroup ? null : groupId ?? this.groupId,
      title: title ?? this.title,
      description: description ?? this.description,
      progressLabel: progressLabel ?? this.progressLabel,
      currentProgress: currentProgress ?? this.currentProgress,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      status: status ?? this.status,
      colorValue: colorValue ?? this.colorValue,
      coverImageUrl: clearCoverImageUrl ? null : coverImageUrl ?? this.coverImageUrl,
      localImagePath: clearLocalImagePath ? null : localImagePath ?? this.localImagePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
