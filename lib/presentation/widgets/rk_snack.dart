import 'package:flutter/material.dart';

import '../../core/constants/app_palette.dart';

class RkSnack {
  RkSnack._();

  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppPalette.danger,
        behavior: SnackBarBehavior.floating,
        content: Text(message),
      ),
    );
  }

  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppPalette.copper,
        behavior: SnackBarBehavior.floating,
        content: Text(message),
      ),
    );
  }
}
