class BindingGrid<K, V> {
  BindingGrid({
    required this.columns,
    required this.nil,
  });

  static BindingGrid<K, V> populated<K, V>({
    required int columns,
    required K nil,
    List<V> keys = const [],
  }) =>
      BindingGrid(
        columns: columns,
        nil: nil,
      )..fill((i) => nil, keys);

  final int columns;
  final K nil;
  Map<V, List<K>> values = {};

  Map<K, V> flatten() => {
        for (var entry in values.entries)
          for (var k in entry.value.whereType<K>()) k: entry.key,
      };

  void fill(K Function(int) generator, List<V> keys) {
    for (V key in keys) {
      values[key] = List.generate(columns, generator);
    }
  }

  K? at(V? k, int col) {
    if (col < 0 || col >= columns) {
      return null;
    }

    return values[k]?[col];
  }

  List<K> row(V k) {
    return values[k] ?? [];
  }

  void emplace(V k, K v, int col) {
    if (col < 0 || col >= columns) {
      return;
    }

    removeWhere((val) => val == v);
    values[k]?[col] = v;
  }

  void append(V k, K v) {
    if (values.containsKey(k)) {
      for (int i = 0; i < (values[k]?.length ?? 0); ++i) {
        if (values[k]?[i] == nil) {
          values[k]?[i] = v;
          return;
        }
      }
    }
  }

  int countValues(K value) {
    return values.values.expand((list) => list).where((v) => v == value).length;
  }

  void removeWhere(bool Function(K v) cb) {
    for (List<K> list in values.values) {
      for (int i = 0; i < list.length; ++i) {
        if (cb(list[i])) {
          list[i] = nil;
        }
      }
    }
  }
}
