import 'dart:collection';

class LruCache<K, V> extends Cache {
  final LinkedHashMap<K, V> _map = LinkedHashMap<K, V>(); // 等同于{}，即Map默认为LinkedHashMap
  final int max;
  final String name;

  LruCache(this.name, this.max);

  // in main thread
  @override
  get(k) {
    V? v = _map.remove(k);
    if (v != null) {
      _map[k] = v;
    }
    return v;
  }

  // in main thread
  @override
  put(k, v) {
    while (_map.length >= max) {
      _map.remove(_map.keys.first);
    }
    _map[k] = v;
    // HpDevice.log('${name}_cache.length: ${_map.length}');
  }

  Iterable<V> values() => _map.values;
}

abstract class Cache<K, V> {
  void put(K k, V v);

  V? get(K k);
}
