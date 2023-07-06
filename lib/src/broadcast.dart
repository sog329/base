import 'dart:async';

import 'package:base/base.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Broadcast<T> {
  final StreamController<T> _ctrl = StreamController.broadcast();
  late T _value;

  Broadcast(this._value) {
    add(_value);
  }

  Stream<T> stream() => _ctrl.stream;

  void add(T t) {
    _value = t;
    _ctrl.add(t);
  }

  T value() => _value;
}

class Percent extends Broadcast<double> {
  final double space;
  Timer? _timer;
  int? _startTime;

  Percent(super.value, {this.space = .05});

  void anim(double t, {required int ms, int? times}) {
    _stopTimer();
    times = (space > 0 ? 1 ~/ space : 100);
    _startTime = HpDevice.time();
    double from = value();
    double delta = t - from;
    _timer = Timer.periodic(
      Duration(milliseconds: ms ~/ times),
      (_) {
        double percent = (HpDevice.time() - _startTime!) / ms;
        if (percent >= 1) {
          percent = 1;
          _stopTimer();
        }
        double v = from + delta * percent;
        super.add(_format(v));
      },
    );
  }

  void _stopTimer() {
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
      _startTime = null;
    }
  }

  double _format(double t) {
    if (space > 0) {
      int n = t ~/ space;
      double d = t - n * space;
      t = (n + (d >= space / 2 ? 1 : 0)) * space;
    }
    return t;
  }

  @override
  void add(double t) {
    _stopTimer();
    super.add(_format(t));
  }
}

class PercentWidget extends StreamWidget<double> {
  PercentWidget({
    super.key,
    double Function(double d)? convert,
    required Percent percent,
    required Widget Function(BuildContext ctx, double p, Widget? child) builder,
    Widget? child,
  }) : super(
          initialData: convert == null ? percent.value() : convert(percent.value()),
          stream:
              convert == null ? percent.stream().distinct() : percent.stream().map((d) => convert.call(d)).distinct(),
          builder: (ctx, snap, __) => builder.call(ctx, snap.data!, child),
        );
}
