import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_palette.dart';
import '../providers/rkeeper_provider.dart';
import '../widgets/decorated_scaffold.dart';
import '../widgets/media_item_card.dart';
import '../widgets/visual_card.dart';
import 'item_form_screen.dart';

class GroupDetailScreen extends StatelessWidget {
  const GroupDetailScreen({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context) {
    return Consumer<RKeeperProvider>(
      builder: (context, provider, _) {
        final group = provider.groupById(groupId);
        if (group == null) {
          return DecoratedScaffold(
            body: Center(
              child: TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Group not found'),
              ),
            ),
          );
        }
        final items = provider.itemsFor(categoryId: group.categoryId, groupId: group.id);
        return DecoratedScaffold(
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ItemFormScreen(categoryId: group.categoryId, groupId: group.id))),
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
                        child: Text(group.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
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
                      title: group.title,
                      subtitle: group.description.isEmpty ? provider.categoryTitle(group.categoryId) : group.description,
                      colorValue: group.colorValue,
                      imageUrl: group.imageUrl,
                      localImagePath: group.localImagePath,
                      trailingText: '${items.length} items',
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(22, 26, 22, 10),
                sliver: const SliverToBoxAdapter(child: Text('Items', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900))),
              ),
              if (items.isEmpty)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  sliver: SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppPalette.panel.withOpacity(0.70),
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(color: AppPalette.cream.withOpacity(0.08)),
                      ),
                      child: Text('No item inside this group yet.', style: TextStyle(color: AppPalette.mutedCream.withOpacity(0.88))),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  sliver: SliverList.builder(
                    itemCount: items.length,
                    itemBuilder: (_, index) => MediaItemCard(item: items[index]),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 95)),
            ],
          ),
        );
      },
    );
  }
}
