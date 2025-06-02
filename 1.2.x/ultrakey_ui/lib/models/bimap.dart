class BiMap<K, V> {
  final Map<K, V> _forward = {};
  final Map<V, K> _reverse = {};

  BiMap.from(Map<K, V> map) {
    for (var entry in map.entries) {
      add(entry.key, entry.value);
    }
  }

  void add(K key, V value) {
    if (_forward.containsKey(key)) {
      _reverse.remove(_forward[key]);
    }
    if (_reverse.containsKey(value)) {
      _forward.remove(_reverse[value]);
    }
    _forward[key] = value;
    _reverse[value] = key;
  }

  V? operator [](K key) => _forward[key];
  K? reverse(V value) => _reverse[value];

  bool containsKey(K key) => _forward.containsKey(key);
  bool containsValue(V value) => _reverse.containsKey(value);

  Iterable<K> get keys => _forward.keys;
  Iterable<V> get values => _reverse.keys;

  void removeByKey(K key) {
    if (_forward.containsKey(key)) {
      final val = _forward.remove(key);
      _reverse.remove(val);
    }
  }

  void removeByValue(V value) {
    if (_reverse.containsKey(value)) {
      final key = _reverse.remove(value);
      _forward.remove(key);
    }
  }

  void clear() {
    _forward.clear();
    _reverse.clear();
  }
}
