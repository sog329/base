import 'package:anim_studio/base/lru_cache.dart';
import 'package:flutter/foundation.dart';

class ConfigLruCache {
  ConfigLruCache._();

  static final LruCache<String, Uint8List> _cache = LruCache('config', 60);

  static bool _can(String k) => k.endsWith('config.xml');

  static Uint8List? get(String k) => _can(k) ? _cache.get(k) : null;

  static void put(String k, Uint8List v) {
    if (_can(k)) {
      _cache.put(k, v);
    }
  }
}
