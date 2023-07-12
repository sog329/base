import 'dart:math';

import 'package:base/src/hp_platform.dart';
import 'package:base/src/hp_thread.dart';
import 'package:base/src/navi_obs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

class HpDevice {
  HpDevice._();

  static double screenWidth(BuildContext c, [double? p]) => _percent(MediaQuery.of(c).size.width, p);

  static double screenHeight(BuildContext c, [double? p]) => _percent(MediaQuery.of(c).size.height, p);

  static double pixelRatio(BuildContext c) => MediaQuery.of(c).devicePixelRatio;

  static double screenMin(BuildContext c, [double? p]) {
    Size s = MediaQuery.of(c).size;
    return _percent(min(s.width, s.height), p);
  }

  static double _percent(double d, double? p) => p == null ? d : d * p;

  static int time() => DateTime.now().millisecondsSinceEpoch;

  static void log(String s) {
    DateTime now = DateTime.now();
    s = '${DateFormat('HH:mm:ss').format(now)}.${now.millisecond..toStringAsFixed(3)}[${HpThread.current()}]:$s';
    // if (kDebugMode) {
    print(s);
    // }
  }

  static void toast(String? s) {
    if (HpPlatform.isWeb() && s != null) {
      Fluttertoast.showToast(
        msg: s,
        toastLength: Toast.LENGTH_LONG,
        webPosition: 'center',
      );
    } else if (HpPlatform.isAndroid() || HpPlatform.isIOS()) {
      Fluttertoast.cancel();
      if (s != null) {
        Fluttertoast.showToast(msg: s);
      }
    } else {
      BuildContext? ctx = NaviObs.ctx();
      if (s != null && ctx != null) {
        snackBar(ctx, s);
      }
    }
  }

  static void snackBar(BuildContext ctx, String s) => ScaffoldMessenger.of(ctx)
    ..removeCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(s),
        action: SnackBarAction(
          label: 'Hide',
          onPressed: () {},
        ),
      ),
    );

  static void orientation(bool portrait) {
    if (portrait) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
  }

  static Exception exp(String s) {
    HpDevice.log(s);
    return Exception(s);
  }

  static Future<bool> permission(Permission p) {
    if (HpPlatform.isAndroid()) {
      return p.request().then(
        (s) {
          if (!s.isGranted) {
            openAppSettings();
          }
          return Future.value(s.isGranted);
        },
      );
    } else {
      return Future.value(true);
    }
  }
}
