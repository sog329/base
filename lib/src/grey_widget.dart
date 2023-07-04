import 'dart:async';

import 'package:base/src/stream_widget.dart';
import 'package:flutter/material.dart';

class GreyWidget extends StreamWidget<bool> {
  GreyWidget({
    super.key,
    super.initialData,
    required Widget child,
  }) : super(
          stream: GreyProvider._ctrl.stream,
          child: child,
          builder: (c, s, child) {
            assert(child!.key is GlobalKey);
            if (GreyProvider.grey()) {
              return ColorFiltered(
                colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.saturation),
                child: child,
              );
            } else {
              return child!;
            }
          },
        );
}

class GreyProvider {
  GreyProvider._();

  static final StreamController<bool> _ctrl = StreamController.broadcast();
  static bool _grey = false;

  static StreamController<bool> ctrl() => _ctrl;

  static void change(b) {
    if (_grey != b) {
      _grey = b;
      _ctrl.add(_grey);
    }
  }

  static bool grey() => _grey;
}
