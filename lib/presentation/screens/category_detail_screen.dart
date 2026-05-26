import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_palette.dart';
import '../../domain/entities/group_entity.dart';
import '../providers/rkeeper_provider.dart';
import '../widgets/decorated_scaffold.dart';
import '../widgets/entity_form_sheet.dart';
import '../widgets/media_item_card.dart';
import '../widgets/rk_snack.dart';
import '../widgets/visual_card.dart';
import 'group_detail_screen.dart';
import 'item_form_screen.dart';

class CategoryDetailScreen extends StatelessWidget {
  const CategoryDetailScreen({super.key, required this.categoryId});

  final String categoryId;

  @override
  Widget build(BuildContext context) {
    return Consumer<RKeeperProvider>(
      builder: (context, provider, _) {
        final category = provider.categoryById(categoryId);
        if (category == null) {
          return DecoratedScaffold(
            body: Center(
              child: TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Category not found'),
              ),
            ),
          );
        }
        final groups = provider.groupsFor(categoryId);
        final ungroupedItems = provider.itemsFor(categoryId: categoryId);
        return DecoratedScaffold(
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ItemFormScreen(categoryId: categoryId))),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Item'),
          ),
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios_new_rounded)),
                      Expanded(
                        child: Text(category.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(22, 12, 22, 0),
                sliver: SliverToBoxAdapter(
                  child: SizedBox(
                    height: 210,
                    child: VisualCard(
                      title: category.title,
                      subtitle: category.description.isEmpty ? 'Category dashboard' : category.description,
                      colorValue: category.colorValue,
                      imageUrl: category.imageUrl,
                      localImagePath: category.localImagePath,
                      trailingText: '${groups.length} groups • ${provider.items.where((item) => item.categoryId == categoryId).length} items',
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(22, 26, 22, 10),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      const Expanded(child: Text('Groups', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900))),
                      TextButton.icon(
                        onPressed: () => _createGroup(context, categoryId),
                        icon: const Icon(Icons.create_new_folder_rounded, size: 18),
                        label: const Text('New group'),
                      ),
                    ],
                  ),
                ),
              ),
              if (groups.isEmpty)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  sliver: SliverToBoxAdapter(child: _InfoBox(message: 'No group yet. Add one for seasons, backlog, completed, or custom folders.')),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  sliver: SliverGrid.builder(
                    itemCount: groups.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.84,
                    ),
                    itemBuilder: (context, index) {
                      final group = groups[index];
                      final count = provider.itemsFor(categoryId: categoryId, groupId: group.id).length;
                      return VisualCard(
                        title: group.title,
                        subtitle: group.description.isEmpty ? '$count items' : group.description,
                        trailingText: '$count items',
                        colorValue: group.colorValue,
                        imageUrl: group.imageUrl,
                        localImagePath: group.localImagePath,
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => GroupDetailScreen(groupId: group.id))),
                        onEdit: () => _editGroup(context, group),
                        onDelete: () => _deleteGroup(context, group),
                      );
                    },
                  ),
                ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(22, 28, 22, 10),
                sliver: const SliverToBoxAdapter(child: Text('Ungrouped Items', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900))),
              ),
              if (ungroupedItems.isEmpty)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  sliver: SliverToBoxAdapter(child: _InfoBox(message: 'Items created without a group will appear here.')),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  sliver: SliverList.builder(
                    itemCount: ungroupedItems.length,
                    itemBuilder: (_, index) => MediaItemCard(item: ungroupedItems[index]),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 95)),
            ],
          ),
        );
      },
    );
  }

  Future<void> _createGroup(BuildContext context, String categoryId) async {
    final data = await EntityFormSheet.show(context, heading: 'New Group', submitLabel: 'Create group');
    if (data == null || !context.mounted) return;
    final ok = await context.read<RKeeperProvider>().createGroup(
          categoryId: categoryId,
          title: data.title,
          description: data.description,
          colorValue: data.colorValue,
          imageUrl: data.imageUrl,
          localImagePath: data.localImagePath,
        );
    if (!ok && context.mounted) RkSnack.showError(context, context.read<RKeeperProvider>().errorMessage ?? 'Group could not be created.');
  }

  Future<void> _editGroup(BuildContext context, GroupEntity group) async {
    final data = await EntityFormSheet.show(
      context,
      heading: 'Edit Group',
      submitLabel: 'Save changes',
      initialTitle: group.title,
      initialDescription: group.description,
      initialColorValue: group.colorValue,
      initialImageUrl: group.imageUrl,
      initialLocalImagePath: group.localImagePath,
    );
    if (data == null || !context.mounted) return;
    final ok = await context.read<RKeeperProvider>().updateGroup(
          group.copyWith(
            title: data.title,
            description: data.description,
            colorValue: data.colorValue,
            imageUrl: data.imageUrl,
            localImagePath: data.localImagePath,
            clearImageUrl: data.imageUrl == null,
            clearLocalImagePath: data.localImagePath == null,
          ),
        );
    if (!ok && context.mounted) RkSnack.showError(context, context.read<RKeeperProvider>().errorMessage ?? 'Group could not be updated.');
  }

  Future<void> _deleteGroup(BuildContext context, GroupEntity group) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete group?'),
        content: Text('"${group.title}" and all items inside it will be deleted.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final ok = await context.read<RKeeperProvider>().deleteGroup(group.id);
    if (!ok && context.mounted) RkSnack.showError(context, context.read<RKeeperProvider>().errorMessage ?? 'Group could not be deleted.');
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppPalette.panel.withOpacity(0.70),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppPalette.cream.withOpacity(0.08)),
      ),
      child: Text(message, style: TextStyle(color: AppPalette.mutedCream.withOpacity(0.88))),
    );
  }
}
