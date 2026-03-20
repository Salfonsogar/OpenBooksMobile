class ChapterCache {
  static const int _maxCachedChapters = 10;
  final Map<int, String> _cache = {};
  final List<int> _accessOrder = [];

  String? get(int index) {
    final content = _cache[index];
    if (content != null) {
      _updateAccessOrder(index);
    }
    return content;
  }

  void put(int index, String content) {
    if (_cache.containsKey(index)) {
      _updateAccessOrder(index);
      _cache[index] = content;
      return;
    }

    if (_cache.length >= _maxCachedChapters) {
      _evictOldest();
    }

    _cache[index] = content;
    _accessOrder.add(index);
  }

  bool has(int index) => _cache.containsKey(index);

  void remove(int index) {
    _cache.remove(index);
    _accessOrder.remove(index);
  }

  void clear() {
    _cache.clear();
    _accessOrder.clear();
  }

  int get length => _cache.length;

  List<int> get cachedIndices => List.unmodifiable(_cache.keys);

  void _updateAccessOrder(int index) {
    _accessOrder.remove(index);
    _accessOrder.add(index);
  }

  void _evictOldest() {
    if (_accessOrder.isNotEmpty) {
      final oldestIndex = _accessOrder.first;
      _accessOrder.removeAt(0);
      _cache.remove(oldestIndex);
    }
  }

  void keepOnlyIndices(Set<int> indicesToKeep) {
    final indicesToRemove = _cache.keys.where((k) => !indicesToKeep.contains(k)).toList();
    for (final index in indicesToRemove) {
      remove(index);
    }
  }
}
