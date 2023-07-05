import 'package:flutter/material.dart';

class NavigatorObs extends NavigatorObserver {
  NavigatorObs._();

  static final NavigatorObs _navi = NavigatorObs._();

  factory NavigatorObs.obs() => _navi;

  static BuildContext ctx() => _navi.navigator!.context;

  static final List<RouteSettings> _lst = [];

  static const String _dlg = '[dlg]_';
  static const String _page = '[page]_';

  static bool hasDlg(bool dlg, [String? s]) {
    bool result = false;
    if (_lst.last != null) {
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

  static push(BuildContext ctx, Widget page, {String? args}) => Navigator.push(
        ctx,
        MaterialPageRoute(
          settings: rs(page.runtimeType.toString(), args: args),
          builder: (_) => page,
        ),
      );

  static push2(BuildContext ctx, Widget page, {String? args}) {
    return Navigator.push(
      ctx,
      PageRouteBuilder(
          settings: rs(page.runtimeType.toString(), args: args),
          pageBuilder: (_, __, ___) => page,
          transitionsBuilder: (_, front, back, child) {
            return FadeTransition(
              opacity: Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
                parent: front,
                curve: Curves.fastOutSlowIn,
              )),
              child: child,
            );
          }),
    );
  }

  static String _name(bool dlg, String name) => dlg ? '$_dlg$name' : '$_page$name';

  static RouteSettings rs(String name, {String? args, dlg = false}) => RouteSettings(
        name: _name(dlg, name),
        arguments: args,
      );
}
