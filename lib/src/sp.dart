import 'package:base/src/theme_widget.dart';
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

  SharedPreferences get sp => _sp;

  static void setThemeDark(bool b) => _sp.setBool('theme_dark', b);

  static bool getThemeDark() => _sp.getBool('theme_dark') ?? true;

  static void setThemeColorName(String n) => _sp.setString('theme_color_name', n);

  static String getThemeColorName() => _sp.getString('theme_color_name') ?? ThemeProvider.map.keys.first;

  static void setBaseRatio(int n) => _sp.setInt('theme_scale', n);

  static int getBaseRatio() => _sp.getInt('theme_scale') ?? 12;
}
