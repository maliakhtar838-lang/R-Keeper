import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../core/errors/app_exception.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/group_entity.dart';
import '../../domain/entities/media_item_entity.dart';
import '../../domain/repositories/rkeeper_repository.dart';

class RKeeperProvider extends ChangeNotifier {
  RKeeperProvider(this._repository);

  final RKeeperRepository _repository;
  final _uuid = const Uuid();

  List<CategoryEntity> _categories = [];
  List<GroupEntity> _groups = [];
  List<MediaItemEntity> _items = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  List<CategoryEntity> get categories => List.unmodifiable(_categories);
  List<GroupEntity> get groups => List.unmodifiable(_groups);
  List<MediaItemEntity> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  List<MediaItemEntity> get recentItems {
    final sorted = [..._items]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return sorted;
  }

  List<MediaItemEntity> get searchResults {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return [];
    final result = _items.where((item) {
      return item.title.toLowerCase().contains(query) ||
          item.description.toLowerCase().contains(query) ||
          item.status.label.toLowerCase().contains(query) ||
          item.progressLabel.toLowerCase().contains(query);
    }).toList();
    result.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return result;
  }

  Future<void> bootstrap() async {
    _isLoading = true;
    notifyListeners();
    await _refresh();
    _isLoading = false;
    notifyListeners();
  }

  void setSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  List<GroupEntity> groupsFor(String categoryId) {
    return _groups.where((group) => group.categoryId == categoryId).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  List<MediaItemEntity> itemsFor({required String categoryId, String? groupId}) {
    final filtered = _items.where((item) {
      if (item.categoryId != categoryId) return false;
      if (groupId == null) return item.groupId == null;
      return item.groupId == groupId;
    }).toList();
    filtered.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return filtered;
  }

  CategoryEntity? categoryById(String id) {
    for (final category in _categories) {
      if (category.id == id) return category;
    }
    return null;
  }

  GroupEntity? groupById(String id) {
    for (final group in _groups) {
      if (group.id == id) return group;
    }
    return null;
  }

  String categoryTitle(String id) => categoryById(id)?.title ?? 'Unknown Category';
  String groupTitle(String? id) => id == null ? 'Ungrouped' : groupById(id)?.title ?? 'Group';

  Future<bool> createCategory({
    required String title,
    required String description,
    required int colorValue,
    String? imageUrl,
    String? localImagePath,
  }) async {
    final now = DateTime.now();
    final category = CategoryEntity(
      id: _uuid.v4(),
      title: title.trim(),
      description: description.trim(),
      colorValue: colorValue,
      imageUrl: _emptyToNull(imageUrl),
      localImagePath: _emptyToNull(localImagePath),
      createdAt: now,
      updatedAt: now,
    );
    return _runMutation(() => _repository.upsertCategory(category));
  }

  Future<bool> updateCategory(CategoryEntity category) {
    return _runMutation(() => _repository.upsertCategory(category.copyWith(updatedAt: DateTime.now())));
  }

  Future<bool> deleteCategory(String categoryId) {
    return _runMutation(() => _repository.deleteCategory(categoryId));
  }

  Future<bool> createGroup({
    required String categoryId,
    required String title,
    required String description,
    required int colorValue,
    String? imageUrl,
    String? localImagePath,
  }) async {
    final now = DateTime.now();
    final group = GroupEntity(
      id: _uuid.v4(),
      categoryId: categoryId,
      title: title.trim(),
      description: description.trim(),
      colorValue: colorValue,
      imageUrl: _emptyToNull(imageUrl),
      localImagePath: _emptyToNull(localImagePath),
      createdAt: now,
      updatedAt: now,
    );
    return _runMutation(() => _repository.upsertGroup(group));
  }

  Future<bool> updateGroup(GroupEntity group) {
    return _runMutation(() => _repository.upsertGroup(group.copyWith(updatedAt: DateTime.now())));
  }

  Future<bool> deleteGroup(String groupId) {
    return _runMutation(() => _repository.deleteGroup(groupId));
  }

  Future<bool> createItem({
    required String categoryId,
    required String title,
    required String description,
    required String progressLabel,
    required int currentProgress,
    required String sourceUrl,
    required MediaStatus status,
    required int colorValue,
    String? groupId,
    String? coverImageUrl,
    String? localImagePath,
  }) {
    final now = DateTime.now();
    final item = MediaItemEntity(
      id: _uuid.v4(),
      categoryId: categoryId,
      groupId: _emptyToNull(groupId),
      title: title.trim(),
      description: description.trim(),
      progressLabel: progressLabel.trim().isEmpty ? 'Ch' : progressLabel.trim(),
      currentProgress: currentProgress < 0 ? 0 : currentProgress,
      sourceUrl: sourceUrl.trim(),
      status: status,
      colorValue: colorValue,
      coverImageUrl: _emptyToNull(coverImageUrl),
      localImagePath: _emptyToNull(localImagePath),
      createdAt: now,
      updatedAt: now,
    );
    return _runMutation(() => _repository.upsertItem(item));
  }

  Future<bool> updateItem(MediaItemEntity item) {
    return _runMutation(() => _repository.upsertItem(item.copyWith(updatedAt: DateTime.now())));
  }

  Future<bool> adjustProgress(MediaItemEntity item, int delta) {
    final next = item.currentProgress + delta;
    return updateItem(item.copyWith(currentProgress: next < 0 ? 0 : next, updatedAt: DateTime.now()));
  }

  Future<bool> deleteItem(String itemId) {
    return _runMutation(() => _repository.deleteItem(itemId));
  }

  Future<void> _refresh() async {
    try {
      _errorMessage = null;
      _categories = await _repository.getCategories();
      _groups = await _repository.getGroups();
      _items = await _repository.getItems();
    } catch (error) {
      _errorMessage = error is AppException ? error.message : 'Something went wrong while loading data.';
    }
  }

  Future<bool> _runMutation(Future<void> Function() action) async {
    try {
      _errorMessage = null;
      await action();
      await _refresh();
      notifyListeners();
      return true;
    } catch (error) {
      _errorMessage = error is AppException ? error.message : 'The action could not be completed.';
      notifyListeners();
      return false;
    }
  }

  String? _emptyToNull(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return value.trim();
  }
}
