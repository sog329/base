import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class OnlyOnePointerRecognizer extends OneSequenceGestureRecognizer {
  int _p = 0;

  @override
  void addPointer(PointerDownEvent event) {
    startTrackingPointer(event.pointer);
    if (_p == 0) {
      resolve(GestureDisposition.rejected);
      _p = event.pointer;
    } else {
      resolve(GestureDisposition.accepted);
    }
  }

  @override
  String get debugDescription => 'only one pointer recognizer';

  @override
  void didStopTrackingLastPointer(int pointer) {}

  @override
  void handleEvent(PointerEvent event) {
    if (!event.down && event.pointer == _p) {
      _p = 0;
    }
  }
}

class SingleTouch extends StatelessWidget {
  final Widget child;
  final Map<Type, GestureRecognizerFactory> gestures = {
    OnlyOnePointerRecognizer:
        GestureRecognizerFactoryWithHandlers<OnlyOnePointerRecognizer>(() => OnlyOnePointerRecognizer(), (_) {}),
  };

  SingleTouch({super.key, required this.child});

  @override
  Widget build(BuildContext context) => RawGestureDetector(gestures: gestures, child: child);
}
