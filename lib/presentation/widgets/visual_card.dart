import 'package:flutter/material.dart';

import '../../core/constants/app_palette.dart';
import 'adaptive_image.dart';

class VisualCard extends StatelessWidget {
  const VisualCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.colorValue,
    this.imageUrl,
    this.localImagePath,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.trailingText,
  });

  final String title;
  final String subtitle;
  final int colorValue;
  final String? imageUrl;
  final String? localImagePath;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final String? trailingText;

  @override
  Widget build(BuildContext context) {
    final color = Color(colorValue);
    final hasImage = (imageUrl != null && imageUrl!.trim().isNotEmpty) ||
        (localImagePath != null && localImagePath!.trim().isNotEmpty);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.30),
              blurRadius: 22,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (hasImage)
                AdaptiveImage(imageUrl: imageUrl, localImagePath: localImagePath)
              else
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [color.withOpacity(0.96), AppPalette.black],
                    ),
                  ),
                ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.08),
                        Colors.black.withOpacity(0.18),
                        Colors.black.withOpacity(0.88),
                      ],
                      stops: const [0, 0.48, 1],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 14,
                right: 12,
                child: _CardMenu(onEdit: onEdit, onDelete: onDelete),
              ),
              Positioned(
                left: 18,
                right: 18,
                bottom: 18,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (trailingText != null && trailingText!.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppPalette.cream.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: AppPalette.cream.withOpacity(0.08)),
                        ),
                        child: Text(
                          trailingText!,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                        ),
                      ),
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppPalette.cream,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        height: 1.02,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppPalette.cream.withOpacity(0.78),
                        fontSize: 12,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardMenu extends StatelessWidget {
  const _CardMenu({this.onEdit, this.onDelete});

  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    if (onEdit == null && onDelete == null) return const SizedBox.shrink();
    return PopupMenuButton<String>(
      color: AppPalette.panelLight,
      icon: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.30),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.more_horiz_rounded, color: AppPalette.cream, size: 18),
      ),
      onSelected: (value) {
        if (value == 'edit') onEdit?.call();
        if (value == 'delete') onDelete?.call();
      },
      itemBuilder: (_) => [
        if (onEdit != null)
          const PopupMenuItem(value: 'edit', child: Text('Edit')),
        if (onDelete != null)
          const PopupMenuItem(value: 'delete', child: Text('Delete')),
      ],
    );
  }
}
