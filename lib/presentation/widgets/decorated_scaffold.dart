import 'package:flutter/material.dart';

import '../../core/constants/app_palette.dart';

class DecoratedScaffold extends StatelessWidget {
  const DecoratedScaffold({
    super.key,
    required this.body,
    this.floatingActionButton,
    this.bottomNavigationBar,
  });

  final Widget body;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: AppPalette.black,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppPalette.backgroundGradient,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -110,
              right: -80,
              child: _Glow(color: AppPalette.copper.withOpacity(0.32), size: 240),
            ),
            Positioned(
              bottom: 110,
              left: -120,
              child: _Glow(color: AppPalette.orange.withOpacity(0.16), size: 260),
            ),
            SafeArea(child: body),
          ],
        ),
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withOpacity(0)],
        ),
      ),
    );
  }
}
