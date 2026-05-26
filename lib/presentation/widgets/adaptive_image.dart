import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/constants/app_palette.dart';
import '../../core/utils/validators.dart';

class AdaptiveImage extends StatelessWidget {
  const AdaptiveImage({
    super.key,
    this.imageUrl,
    this.localImagePath,
    this.fit = BoxFit.cover,
  });

  final String? imageUrl;
  final String? localImagePath;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final path = localImagePath?.trim();
    if (path != null && path.isNotEmpty && File(path).existsSync()) {
      return Image.file(
        File(path),
        fit: fit,
        errorBuilder: (_, __, ___) => const _ImageFallback(),
      );
    }

    final url = imageUrl?.trim();
    if (Validators.isValidHttpUrl(url)) {
      return Image.network(
        url!,
        fit: fit,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const _ImageLoading();
        },
        errorBuilder: (_, __, ___) => const _ImageFallback(),
      );
    }

    return const _ImageFallback();
  }
}

class _ImageLoading extends StatelessWidget {
  const _ImageLoading();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppPalette.panelLight,
      child: const Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppPalette.deepCopper, AppPalette.black],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.auto_stories_rounded,
          color: AppPalette.cream.withOpacity(0.24),
          size: 44,
        ),
      ),
    );
  }
}
