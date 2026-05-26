import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/constants/app_palette.dart';

class GlassBottomBar extends StatelessWidget {
  const GlassBottomBar({super.key, required this.onAddCategory, required this.onScrollTop});

  final VoidCallback onAddCategory;
  final VoidCallback onScrollTop;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(34, 0, 34, 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              height: 58,
              decoration: BoxDecoration(
                color: AppPalette.softOrange.withOpacity(0.22),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: AppPalette.cream.withOpacity(0.10)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _NavButton(icon: Icons.home_rounded, label: 'Home', onTap: onScrollTop),
                  _NavButton(icon: Icons.add_rounded, label: 'New', onTap: onAddCategory, highlighted: true),
                  _NavButton(icon: Icons.search_rounded, label: 'Search', onTap: onScrollTop),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.icon, required this.label, required this.onTap, this.highlighted = false});

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: highlighted ? AppPalette.copper.withOpacity(0.72) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppPalette.cream),
            if (highlighted) ...[
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
            ],
          ],
        ),
      ),
    );
  }
}
