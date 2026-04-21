class OfflineReadingException implements Exception {
  final String message;

  OfflineReadingException(this.message);

  @override
  String toString() => message;
}