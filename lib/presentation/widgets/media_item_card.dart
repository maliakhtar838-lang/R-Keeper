import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_palette.dart';
import '../../core/utils/validators.dart';
import '../../domain/entities/media_item_entity.dart';
import '../providers/rkeeper_provider.dart';
import '../screens/item_form_screen.dart';
import 'adaptive_image.dart';
import 'rk_snack.dart';
import 'status_chip.dart';

class MediaItemCard extends StatelessWidget {
  const MediaItemCard({super.key, required this.item, this.compact = false});

  final MediaItemEntity item;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RKeeperProvider>();
    final date = DateFormat('MMM d, h:mm a').format(item.updatedAt);

    return Container(
      margin: EdgeInsets.only(bottom: compact ? 10 : 14),
      decoration: BoxDecoration(
        color: AppPalette.panel.withOpacity(0.82),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppPalette.cream.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.22),
            blurRadius: 22,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          if (!compact)
            SizedBox(
              height: 122,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  AdaptiveImage(imageUrl: item.coverImageUrl, localImagePath: item.localImagePath),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withOpacity(0.72)],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    bottom: 14,
                    child: StatusChip(status: item.status),
                  ),
                  Positioned(
                    right: 10,
                    top: 8,
                    child: _ItemMenu(item: item),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, height: 1.1),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '${provider.categoryTitle(item.categoryId)} • ${provider.groupTitle(item.groupId)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: AppPalette.mutedCream.withOpacity(0.84), fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    if (compact) ...[
                      const SizedBox(width: 10),
                      StatusChip(status: item.status),
                    ],
                  ],
                ),
                if (item.description.trim().isNotEmpty) ...[
                  const SizedBox(height: 9),
                  Text(
                    item.description,
                    maxLines: compact ? 1 : 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: AppPalette.cream.withOpacity(0.72), fontSize: 13),
                  ),
                ],
                const SizedBox(height: 14),
                Row(
                  children: [
                    _RoundButton(
                      icon: Icons.remove_rounded,
                      onTap: () async {
                        final ok = await context.read<RKeeperProvider>().adjustProgress(item, -1);
                        if (!ok && context.mounted) {
                          RkSnack.showError(context, context.read<RKeeperProvider>().errorMessage ?? 'Progress could not be updated.');
                        }
                      },
                    ),
                    Expanded(
                      child: Container(
                        height: 52,
                        margin: const EdgeInsets.symmetric(horizontal: 9),
                        decoration: BoxDecoration(
                          color: AppPalette.black.withOpacity(0.42),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Center(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(text: '${item.progressLabel} ', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                                TextSpan(text: '${item.currentProgress}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    _RoundButton(
                      icon: Icons.add_rounded,
                      onTap: () async {
                        final ok = await context.read<RKeeperProvider>().adjustProgress(item, 1);
                        if (!ok && context.mounted) {
                          RkSnack.showError(context, context.read<RKeeperProvider>().errorMessage ?? 'Progress could not be updated.');
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.schedule_rounded, size: 15, color: AppPalette.mutedCream.withOpacity(0.80)),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        date,
                        style: TextStyle(color: AppPalette.mutedCream.withOpacity(0.50), fontSize: 11),
                      ),
                    ),
                    if (Validators.isValidHttpUrl(item.sourceUrl))
                      IconButton(
                        onPressed: () => _openSource(context, item.sourceUrl),
                        icon: const Icon(Icons.open_in_new_rounded, size: 18),
                        color: AppPalette.softOrange,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openSource(BuildContext context, String url) async {
    try {
      final uri = Uri.parse(url.trim());
      final canLaunch = await canLaunchUrl(uri);
      if (!canLaunch) {
        if (context.mounted) RkSnack.showError(context, 'This link cannot be opened.');
        return;
      }
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (context.mounted) RkSnack.showError(context, 'Something went wrong while opening the link.');
    }
  }
}

class _ItemMenu extends StatelessWidget {
  const _ItemMenu({required this.item});

  final MediaItemEntity item;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      color: AppPalette.panelLight,
      icon: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(color: Colors.black.withOpacity(0.32), shape: BoxShape.circle),
        child: const Icon(Icons.more_horiz_rounded, color: AppPalette.cream, size: 18),
      ),
      onSelected: (value) async {
        if (value == 'edit') {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => ItemFormScreen(existingItem: item, categoryId: item.categoryId)));
        }
        if (value == 'delete') {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Delete item?'),
              content: Text('"${item.title}" will be removed from RKeeper.'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
              ],
            ),
          );
          if (confirmed == true && context.mounted) {
            final ok = await context.read<RKeeperProvider>().deleteItem(item.id);
            if (!ok && context.mounted) RkSnack.showError(context, context.read<RKeeperProvider>().errorMessage ?? 'Item could not be deleted.');
          }
        }
      },
      itemBuilder: (_) => const [
        PopupMenuItem(value: 'edit', child: Text('Edit')),
        PopupMenuItem(value: 'delete', child: Text('Delete')),
      ],
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: AppPalette.copper.withOpacity(0.92),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: AppPalette.copper.withOpacity(0.22), blurRadius: 18, offset: const Offset(0, 8))],
        ),
        child: Icon(icon, color: AppPalette.cream),
      ),
    );
  }
}
