class ProgressCache {
  static final ProgressCache _instance = ProgressCache._internal();
  factory ProgressCache() => _instance;
  ProgressCache._internal();

  final Map<int, _CachedProgress> _cache = {};
  static const Duration _cacheExpiration = Duration(minutes: 5);

  _CachedProgress? get(int libroId) {
    final cached = _cache[libroId];
    if (cached == null) return null;
    
    if (DateTime.now().difference(cached.timestamp) > _cacheExpiration) {
      _cache.remove(libroId);
      return null;
    }
    
    return cached;
  }

  void set(int libroId, double progreso, int page) {
    _cache[libroId] = _CachedProgress(
      progreso: progreso,
      page: page,
      timestamp: DateTime.now(),
    );
  }

  void remove(int libroId) {
    _cache.remove(libroId);
  }

  void clear() {
    _cache.clear();
  }

  List<int> get cachedLibroIds => _cache.keys.toList();
}

class _CachedProgress {
  final double progreso;
  final int page;
  final DateTime timestamp;

  _CachedProgress({
    required this.progreso,
    required this.page,
    required this.timestamp,
  });
}