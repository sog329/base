import 'package:base/src/hp_device.dart';
import 'package:flutter/cupertino.dart';

class QuitContainer extends WillPopScope {
  static DateTime? _preTime;
  static const Duration _duration = Duration(seconds: 1);

  QuitContainer({
    super.key,
    required Widget child,
    required BuildContext context,
    bool intercept = true,
    bool slideOut = false,
  }) : super(onWillPop: () async {
          if (intercept) {
            DateTime now = DateTime.now();
            if (_preTime == null || (now.difference(_preTime!) > _duration)) {
              _preTime = now;
              HpDevice.toast('Quit?');
              return false;
            }
            HpDevice.toast(null);
          }
          return true;
        }, child: () {
          if (slideOut) {
            Offset? from;
            double w = HpDevice.screenMin(context) / 10;
            return GestureDetector(
              onPanDown: (d) {
                from = d.localPosition;
                if (from!.dx > w) {
                  from = null;
                }
              },
              onPanUpdate: (d) {
                if (from != null) {
                  if (d.localPosition.dx - from!.dx >= w && (d.localPosition.dy - from!.dy).abs() <= w) {
                    Navigator.of(context).pop();
                  }
                }
              },
              onPanEnd: (d) => from = null,
              onPanCancel: () => from = null,
              child: child,
            );
          } else {
            return child;
          }
        }());
}
