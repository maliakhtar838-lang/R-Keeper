import '../../core/errors/app_exception.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/group_entity.dart';
import '../../domain/entities/media_item_entity.dart';
import '../../domain/repositories/rkeeper_repository.dart';
import '../models/category_model.dart';
import '../models/group_model.dart';
import '../models/media_item_model.dart';
import '../services/firebase_storage_service.dart';

class RKeeperRepositoryImpl implements RKeeperRepository {
  const RKeeperRepositoryImpl(this._storage);

  final FirebaseStorageService _storage;

  @override
  Future<List<CategoryEntity>> getCategories() async {
    final maps = await _storage.getAll(FirebaseStorageService.categoriesCollection);
    final categories = maps.map(CategoryModel.fromMap).toList();
    categories.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return categories;
  }

  @override
  Future<List<GroupEntity>> getGroups() async {
    final maps = await _storage.getAll(FirebaseStorageService.groupsCollection);
    final groups = maps.map(GroupModel.fromMap).toList();
    groups.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return groups;
  }

  @override
  Future<List<MediaItemEntity>> getItems() async {
    final maps = await _storage.getAll(FirebaseStorageService.itemsCollection);
    final items = maps.map(MediaItemModel.fromMap).toList();
    items.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return items;
  }

  @override
  Future<void> upsertCategory(CategoryEntity category) async {
    await _storage.put(
      FirebaseStorageService.categoriesCollection,
      category.id,
      CategoryModel.fromEntity(category).toMap(),
    );
  }

  @override
  Future<void> upsertGroup(GroupEntity group) async {
    await _storage.put(
      FirebaseStorageService.groupsCollection,
      group.id,
      GroupModel.fromEntity(group).toMap(),
    );
  }

  @override
  Future<void> upsertItem(MediaItemEntity item) async {
    await _storage.put(
      FirebaseStorageService.itemsCollection,
      item.id,
      MediaItemModel.fromEntity(item).toMap(),
    );
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    try {
      final groups = await getGroups();
      final items = await getItems();
      for (final item in items.where((item) => item.categoryId == categoryId)) {
        await _storage.delete(FirebaseStorageService.itemsCollection, item.id);
      }
      for (final group in groups.where((group) => group.categoryId == categoryId)) {
        await _storage.delete(FirebaseStorageService.groupsCollection, group.id);
      }
      await _storage.delete(FirebaseStorageService.categoriesCollection, categoryId);
    } catch (error) {
      throw AppException('Could not delete the category and its contents.', error);
    }
  }

  @override
  Future<void> deleteGroup(String groupId) async {
    try {
      final items = await getItems();
      for (final item in items.where((item) => item.groupId == groupId)) {
        await _storage.delete(FirebaseStorageService.itemsCollection, item.id);
      }
      await _storage.delete(FirebaseStorageService.groupsCollection, groupId);
    } catch (error) {
      throw AppException('Could not delete the group and its items.', error);
    }
  }

  @override
  Future<void> deleteItem(String itemId) async {
    await _storage.delete(FirebaseStorageService.itemsCollection, itemId);
  }
}
