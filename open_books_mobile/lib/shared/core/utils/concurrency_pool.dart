class ConcurrencyPool {
  final int maxConcurrent;

  ConcurrencyPool({this.maxConcurrent = 4});

  Future<List<T>> run<T>(List<Future<T>> tasks) async {
    final results = <T>[];
    final queue = List<Future<T>>.from(tasks);

    while (queue.isNotEmpty) {
      final batch = queue.take(maxConcurrent).toList();
      final completed = await Future.wait(batch);
      results.addAll(completed);
      queue.removeRange(
        0,
        batch.length > queue.length ? queue.length : batch.length,
      );
    }

    return results;
  }
}