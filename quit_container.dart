import 'package:anim_studio/app/base/config.dart';
import 'package:anim_studio/base/hp_device.dart';
import 'package:flutter/cupertino.dart';

class QuitContainer extends WillPopScope {
  static DateTime? _preTime;
  static const Duration _duration = Duration(seconds: 1);

  QuitContainer({
    super.key,
    required super.child,
  }) : super(
          onWillPop: () async {
            DateTime now = DateTime.now();
            if (_preTime == null || (now.difference(_preTime!) > _duration)) {
              _preTime = now;
              HpDevice.toast(Config.exit);
              return false;
            }
            HpDevice.toast(null);
            return true;
          },
        );
}
