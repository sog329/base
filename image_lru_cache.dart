import 'dart:ui';

import 'package:anim_studio/base/hp_device.dart';

import 'lru_cache.dart';

class ImageLruCache {
  static final LruCache<String, Image> _small = LruCache('image_small', 60);
  static final LruCache<String, Image> _normal = LruCache('image_normal', 16); // 56mb

  static bool _isNormal(Image img) => img.width * img.height > 1280 * 720; // ≈3.5mb

  static Image? get(String k) => _small.get(k) ?? _normal.get(k);

  static void put(String k, Image v) => _isNormal(v) ? _normal.put(k, v) : _small.put(k, v);

  static void show() {
    double sum = 0;
    for (Image img in _small.values()) {
      sum += img.width * img.height / 256 / 1024;
    }
    String s = '_small: ${sum.toStringAsFixed(2)}';
    sum = 0;
    for (Image img in _normal.values()) {
      sum += img.width * img.height / 256 / 1024;
    }
    HpDevice.log('${s}mb, _normal: ${sum.toStringAsFixed(2)}mb');
  }
}
