// ignore_for_file: avoid_classes_with_only_static_members
class RetryHandler {
  static const int maxAttempts = 3;
  static const int baseDelayMs = 1000;

  static Future<T> withBackoff<T>(
    Future<T> Function() fn, {
    bool Function(Exception)? onRetry,
  }) async {
    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        return await fn();
      } on Exception catch (e) {
        if (attempt == maxAttempts - 1) rethrow;

        final shouldRetry = onRetry?.call(e);
        if (shouldRetry == false) {
          rethrow;
        }

        final delay = (1 << attempt) * baseDelayMs;
        await Future.delayed(Duration(milliseconds: delay));
      }
    }
    throw Exception('Max retries exceeded');
  }
}