import 'package:flutter/material.dart';

import '../../core/constants/app_palette.dart';
import '../../domain/entities/media_item_entity.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});

  final MediaStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _colorFor(status).withOpacity(0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _colorFor(status).withOpacity(0.30)),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: _colorFor(status),
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.1,
        ),
      ),
    );
  }

  Color _colorFor(MediaStatus status) {
    switch (status) {
      case MediaStatus.reading:
        return AppPalette.softOrange;
      case MediaStatus.watching:
        return AppPalette.sand;
      case MediaStatus.onHold:
        return AppPalette.blueGrey;
      case MediaStatus.dropped:
        return AppPalette.danger;
      case MediaStatus.completed:
        return AppPalette.success;
      case MediaStatus.planToWatch:
        return AppPalette.mutedCream;
    }
  }
}
