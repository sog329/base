import 'package:base/base.dart';
import 'package:base/src/hp_str.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Sp<V> {
  final String k;
  final V d;

  Sp(this.k, this.d);

  V get() => _get<V>(k) ?? d;

  Future<bool> set(V v) => _set<V>(k, v);

  Future<bool> remove() => _sp.remove(k);

  // static
  static late SharedPreferences _sp;

  static Future init() => SharedPreferences.getInstance().then(
        (sp) {
          _sp = sp;
          return Future.value();
        },
      );

  static T? _get<T>(String k) {
    Object? v = _sp.get(k);
    return v != null && v is T ? v as T : null;
  }

  static Future<bool> _set<T>(String k, T v) {
    late Future<bool> fail = Future.value(false);
    if (v is int) {
      return _sp.setInt(k, v);
    } else if (v is double) {
      return _sp.setDouble(k, v);
    } else if (v is bool) {
      return _sp.setBool(k, v);
    } else if (v is String) {
      double kb = HpStr.kb(v);
      if (kb <= 10) {
        return _sp.setString(k, v);
      } else {
        HpDevice.log('Sp.set($k): String.kb=$kb, too large to save');
        return fail;
      }
    } else if (v is List<String>) {
      double kb = 0;
      for (String s in v) {
        kb += HpStr.kb(s);
        if (kb > 10) {
          HpDevice.log('Sp.set($k): List<String>.kb=$kb, too large to save');
          return fail;
        }
      }
      return _sp.setStringList(k, v);
    } else {
      HpDevice.log('Sp.set($k): unknownType=${T.runtimeType}');
      return fail;
    }
  }

  static Future<void> clear() => _sp.clear();
}
