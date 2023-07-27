import 'dart:async';

import 'package:base/src/sp.dart';
import 'package:base/src/stream_widget.dart';
import 'package:flutter/material.dart';

class ThemeWidget extends StreamWidget<ThemeData> {
  ThemeWidget({
    super.key,
    required Widget Function(BuildContext ctx, Widget? child) builder,
    Widget? child,
  }) : super(
          stream: ThemeProvider._ctrl.stream,
          child: child,
          initialData: ThemeProvider.data(),
          builder: (c, s, child) => builder.call(c, child),
        );
}

class ThemeProvider {
  static final Sp<bool> _spDark = Sp('theme_dark', true);
  static final Sp<String> _spColorName = Sp('theme_color_name', ThemeProvider.map.keys.first);
  static final Sp<int> spScale = Sp('theme_scale', 12);

  static ThemeData _data = _build(_spDark.get(), _spColorName.get()); // sp获取
  static final StreamController<ThemeData> _ctrl = StreamController.broadcast();

  ThemeProvider._();

  static ThemeData _build(bool dark, String colorName) => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: map[colorName]!,
          brightness: dark ? Brightness.dark : Brightness.light,
          backgroundColor: dark ? Colors.black : Colors.white,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: map[colorName]!,
          unselectedItemColor: (dark ? Colors.white : Colors.black).withOpacity(.5),
        ),
      );

  static void change({bool? dark, String? colorName, int? ratio}) {
    // theme
    String n = currentColorName();
    bool d = isDark();
    bool change = false;
    if (dark != d || colorName != n) {
      change = true;
      dark = dark ?? d;
      colorName = colorName ?? n;
      _data = _build(dark, colorName);
      _spDark.set(dark);
      _spColorName.set(colorName);
    }
    // ratio
    if (ratio != null && ratio != spScale.get()) {
      change = true;
      spScale.set(ratio);
    }
    // notif
    if (change) {
      _ctrl.add(_data);
    }
  }

  static String currentColorName() {
    List<String> lst = map.keys.toList();
    String s = lst[0];
    for (String k in lst) {
      if (_data.colorScheme.primary == map[k]) {
        s = k;
        break;
      }
    }
    return s;
  }

  static ThemeData data() => _data;

  static bool isDark() => _data.brightness == Brightness.dark;

  static Color currentColor() => map[ThemeProvider.currentColorName()]!;

  static final Map<String, MaterialColor> map = {
    'lime': Colors.lime,
    'amber': Colors.amber,
    'lightBlue': Colors.lightBlue,
    'teal': Colors.teal,
    'pink': Colors.pink,
    'cyan': Colors.cyan,
    'brown': Colors.brown,
    'grey': Colors.grey,
    'blueGrey': Colors.blueGrey,
    'purple': Colors.purple,
    'deepPurple': Colors.deepPurple,
    'indigo': Colors.indigo,
  };
}
