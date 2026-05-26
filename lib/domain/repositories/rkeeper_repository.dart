import '../entities/category_entity.dart';
import '../entities/group_entity.dart';
import '../entities/media_item_entity.dart';

abstract class RKeeperRepository {
  Future<List<CategoryEntity>> getCategories();
  Future<List<GroupEntity>> getGroups();
  Future<List<MediaItemEntity>> getItems();

  Future<void> upsertCategory(CategoryEntity category);
  Future<void> upsertGroup(GroupEntity group);
  Future<void> upsertItem(MediaItemEntity item);

  Future<void> deleteCategory(String categoryId);
  Future<void> deleteGroup(String groupId);
  Future<void> deleteItem(String itemId);
}
