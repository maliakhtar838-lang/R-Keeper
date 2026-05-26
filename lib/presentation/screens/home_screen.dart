import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_palette.dart';
import '../../data/services/auth_service.dart';
import '../../domain/entities/category_entity.dart';
import '../providers/rkeeper_provider.dart';
import '../widgets/decorated_scaffold.dart';
import '../widgets/entity_form_sheet.dart';
import '../widgets/glass_bottom_bar.dart';
import '../widgets/media_item_card.dart';
import '../widgets/rk_snack.dart';
import '../widgets/visual_card.dart';
import 'category_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<RKeeperProvider>().bootstrap();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RKeeperProvider>(
      builder: (context, provider, _) {
        return DecoratedScaffold(
          bottomNavigationBar: GlassBottomBar(
            onAddCategory: () => _createCategory(context),
            onScrollTop: () => _scrollController.animateTo(0, duration: const Duration(milliseconds: 380), curve: Curves.easeOutCubic),
          ),
          body: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: () => provider.bootstrap(),
                  color: AppPalette.orange,
                  backgroundColor: AppPalette.panel,
                  child: CustomScrollView(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(22, 24, 22, 0),
                          sliver: SliverToBoxAdapter(child: _Header(provider: provider)),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
                          sliver: SliverToBoxAdapter(
                            child: TextField(
                              onChanged: provider.setSearchQuery,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.search_rounded),
                                hintText: 'Search books, comics, manga, shows...',
                              ),
                            ),
                          ),
                        ),
                        if (provider.searchQuery.trim().isNotEmpty) ..._searchSlivers(provider) else ..._dashboardSlivers(provider),
                        const SliverToBoxAdapter(child: SizedBox(height: 110)),
                      ],
                    ),
                ),
        );
      },
    );
  }

  List<Widget> _searchSlivers(RKeeperProvider provider) {
    final results = provider.searchResults;
    return [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 10),
        sliver: SliverToBoxAdapter(
          child: _SectionHeader(title: 'Search Results'),
        ),
      ),
      if (results.isEmpty)
        const SliverPadding(
          padding: EdgeInsets.fromLTRB(22, 0, 22, 0),
          sliver: SliverToBoxAdapter(child: _EmptyState(message: 'No matching item yet.')),
        )
      else
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          sliver: SliverList.builder(
            itemCount: results.length,
            itemBuilder: (_, index) => MediaItemCard(item: results[index], compact: true),
          ),
        ),
    ];
  }

  List<Widget> _dashboardSlivers(RKeeperProvider provider) {
    return [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(22, 26, 22, 10),
        sliver: const SliverToBoxAdapter(child: _SectionHeader(title: 'Categories')),
      ),
      if (provider.categories.isEmpty)
        const SliverPadding(
          padding: EdgeInsets.fromLTRB(22, 0, 22, 0),
          sliver: SliverToBoxAdapter(child: _EmptyState(message: 'Create your first category to start tracking.')),
        )
      else
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          sliver: SliverGrid.builder(
            itemCount: provider.categories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 0.82,
            ),
            itemBuilder: (context, index) {
              final category = provider.categories[index];
              return VisualCard(
                title: category.title,
                subtitle: category.description.isNotEmpty ? category.description : _categorySubtitle(provider, category),
                colorValue: category.colorValue,
                imageUrl: category.imageUrl,
                localImagePath: category.localImagePath,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CategoryDetailScreen(categoryId: category.id))),
                onEdit: () => _editCategory(context, category),
                onDelete: () => _deleteCategory(context, category),
              );
            },
          ),
        ),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(22, 26, 22, 10),
        sliver: const SliverToBoxAdapter(child: _SectionHeader(title: 'Recently Updated')),
      ),
      if (provider.recentItems.isEmpty)
        const SliverPadding(
          padding: EdgeInsets.fromLTRB(22, 0, 22, 0),
          sliver: SliverToBoxAdapter(child: _EmptyState(message: 'Progress updates will appear here.')),
        )
      else
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          sliver: SliverList.builder(
            itemCount: provider.recentItems.take(5).length,
            itemBuilder: (_, index) => MediaItemCard(item: provider.recentItems[index], compact: true),
          ),
        ),
    ];
  }

  String _categorySubtitle(RKeeperProvider provider, CategoryEntity category) {
    final items = provider.items.where((item) => item.categoryId == category.id).length;
    return '$items items tracked';
  }

  Future<void> _createCategory(BuildContext context) async {
    final data = await EntityFormSheet.show(context, heading: 'New Category', submitLabel: 'Create category');
    if (data == null || !context.mounted) return;
    final ok = await context.read<RKeeperProvider>().createCategory(
          title: data.title,
          description: data.description,
          colorValue: data.colorValue,
          imageUrl: data.imageUrl,
          localImagePath: data.localImagePath,
        );
    if (!ok && context.mounted) RkSnack.showError(context, context.read<RKeeperProvider>().errorMessage ?? 'Category could not be created.');
  }

  Future<void> _editCategory(BuildContext context, CategoryEntity category) async {
    final data = await EntityFormSheet.show(
      context,
      heading: 'Edit Category',
      submitLabel: 'Save changes',
      initialTitle: category.title,
      initialDescription: category.description,
      initialColorValue: category.colorValue,
      initialImageUrl: category.imageUrl,
      initialLocalImagePath: category.localImagePath,
    );
    if (data == null || !context.mounted) return;
    final ok = await context.read<RKeeperProvider>().updateCategory(
          category.copyWith(
            title: data.title,
            description: data.description,
            colorValue: data.colorValue,
            imageUrl: data.imageUrl,
            localImagePath: data.localImagePath,
            clearImageUrl: data.imageUrl == null,
            clearLocalImagePath: data.localImagePath == null,
          ),
        );
    if (!ok && context.mounted) RkSnack.showError(context, context.read<RKeeperProvider>().errorMessage ?? 'Category could not be updated.');
  }

  Future<void> _deleteCategory(BuildContext context, CategoryEntity category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete category?'),
        content: Text('"${category.title}" and all its groups/items will be deleted.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final ok = await context.read<RKeeperProvider>().deleteCategory(category.id);
    if (!ok && context.mounted) RkSnack.showError(context, context.read<RKeeperProvider>().errorMessage ?? 'Category could not be deleted.');
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.provider});

  final RKeeperProvider provider;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('RKeeper', style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 36)),
              const SizedBox(height: 4),
              Text(
                'Track your progress in books, shows, and more.',
                style: TextStyle(color: AppPalette.mutedCream.withOpacity(0.70), height: 1.2),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Sign Out'),
                content: const Text('Are you sure you want to sign out?'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Sign Out', style: TextStyle(color: AppPalette.danger)),
                  ),
                ],
              ),
            );
            if (confirm == true) {
              await AuthService().signOut();
            }
          },
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppPalette.copper.withOpacity(0.24),
              shape: BoxShape.circle,
              border: Border.all(color: AppPalette.cream.withOpacity(0.10)),
            ),
            child: const Icon(Icons.logout_rounded, color: AppPalette.softOrange, size: 20),
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900));
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppPalette.panel.withOpacity(0.72),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppPalette.cream.withOpacity(0.08)),
      ),
      child: Text(message, style: TextStyle(color: AppPalette.mutedCream.withOpacity(0.86))),
    );
  }
}
