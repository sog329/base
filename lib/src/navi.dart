import 'package:base/base.dart';
import 'package:flutter/material.dart';

class Navi extends NavigatorObserver {
  static final Broadcast<bool> _appResumed = Broadcast(true);

  Navi._();

  static final Navi _navi = Navi._();

  factory Navi.obs() => _navi;

  static BuildContext? ctx() => _navi.navigator?.context;

  static final List<RouteSettings> _lst = [];

  static const String _dlg = '[dlg]_';
  static const String _page = '[page]_';

  static bool hasDlg(bool dlg, [String? s]) {
    bool result = false;
    if (_lst.isNotEmpty) {
      String? name = _lst.last.name;
      if (name != null) {
        result = name.startsWith(_dlg);
        if (s != null) {
          result = name == _name(true, s);
        }
      }
    }
    return result;
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _lst.add(route.settings);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _lst.remove(route.settings);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    RouteSettings? s = oldRoute?.settings;
    if (s != null) {
      _lst.remove(s);
    }
    s = newRoute?.settings;
    if (s != null) {
      _lst.add(s);
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _lst.remove(route.settings);
  }

  static void pop<T extends Object?>(BuildContext c, [T? result]) => Navigator.of(c).pop(result);

  static Future<T?> push<T extends Object?>(BuildContext ctx, Widget page, {String? args}) => Navigator.push(
        ctx,
        MaterialPageRoute(
          settings: rs(page.runtimeType.toString(), args: args),
          builder: (_) => page,
        ),
      );

  static Future<T?> pushAlpha<T extends Object?>(
    BuildContext ctx,
    Widget page, {
    String? args,
    void Function(double p)? onEnter,
    void Function(double p)? onBack,
  }) =>
      Navigator.push(
        ctx,
        PageRouteBuilder(
            settings: rs(page.runtimeType.toString(), args: args),
            pageBuilder: (_, __, ___) => page,
            transitionsBuilder: (_, anim, __, child) {
              if (onEnter != null || onBack != null) {
                bool enter = true;
                anim.addStatusListener(
                  (status) {
                    if (status == AnimationStatus.reverse) {
                      enter = false;
                    } else if (status == AnimationStatus.forward) {
                      enter = true;
                    }
                  },
                );
                anim.addListener(
                  () {
                    if (enter) {
                      onEnter?.call(anim.value);
                    } else {
                      onBack?.call(anim.value);
                    }
                  },
                );
              }
              return FadeTransition(
                opacity: Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
                  parent: anim,
                  curve: Curves.fastOutSlowIn,
                  reverseCurve: Curves.fastOutSlowIn.flipped,
                )),
                child: child,
              );
            }),
      );

  static String _name(bool dlg, String name) => dlg ? '$_dlg$name' : '$_page$name';

  static RouteSettings rs(String name, {String? args, dlg = false}) => RouteSettings(
        name: _name(dlg, name),
        arguments: args,
      );

  static void didChangeAppLifecycleState(AppLifecycleState state) =>
      _appResumed.add(state == AppLifecycleState.resumed);

  static Stream<bool> get resumed => _appResumed.stream();
}
