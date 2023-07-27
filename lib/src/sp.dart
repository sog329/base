import 'package:base/base.dart';
import 'package:base/src/hp_str.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Sp {
  Sp._();

  static late SharedPreferences _sp;

  static Future init() => SharedPreferences.getInstance().then(
        (sp) {
          _sp = sp;
          return Future.value();
        },
      );

  static void setThemeDark(bool b) => _sp.setBool('theme_dark', b);

  static bool getThemeDark() => _sp.getBool('theme_dark') ?? true;

  static void setThemeColorName(String n) => _sp.setString('theme_color_name', n);

  static String getThemeColorName() => _sp.getString('theme_color_name') ?? ThemeProvider.map.keys.first;

  static void setBaseRatio(int n) => _sp.setInt('theme_scale', n);

  static int getBaseRatio() => _sp.getInt('theme_scale') ?? 12;

  static T? get<T>(String k) {
    switch (T.runtimeType) {
      case int:
        return _sp.getInt(k) as T?;
      case double:
        return _sp.getDouble(k) as T?;
      case bool:
        return _sp.getBool(k) as T?;
      case String:
        return _sp.getString(k) as T?;
      default:
        HpDevice.log('Sp.get(): unknownType=${T.runtimeType}');
        return null;
    }
  }

  static Future<bool> set<T>(String k, T v) {
    late Future<bool> fail = Future.value(false);
    switch (T.runtimeType) {
      case int:
        return _sp.setInt(k, v as int);
      case double:
        return _sp.setDouble(k, v as double);
      case bool:
        return _sp.setBool(k, v as bool);
      case String:
        String s = v as String;
        double kb = HpStr.kb(s);
        if (kb <= 10) {
          return _sp.setString(k, s);
        } else {
          HpDevice.log('Sp.set(): String.kb=$kb, too large to save');
          return fail;
        }
      default:
        HpDevice.log('Sp.set(): unknownType=${T.runtimeType}');
        return fail;
    }
  }

  static Future<void> clear() => _sp.clear();
}
