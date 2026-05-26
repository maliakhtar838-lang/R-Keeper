class Validators {
  Validators._();

  static bool isValidHttpUrl(String? value) {
    if (value == null || value.trim().isEmpty) return false;
    final uri = Uri.tryParse(value.trim());
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https') && uri.host.isNotEmpty;
  }

  static String normalizeUrl(String value) => value.trim();

  static int safeProgress(String value) {
    final parsed = int.tryParse(value.trim());
    if (parsed == null || parsed < 0) return 0;
    return parsed;
  }
}
