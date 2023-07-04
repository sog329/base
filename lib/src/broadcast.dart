import 'dart:async';

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

  Percent(super.value, {this.space = .05});

  @override
  void add(double t) {
    if (space > 0) {
      int n = t ~/ space;
      double d = t - n * space;
      t = (n + (d >= space / 2 ? 1 : 0)) * space;
    }
    super.add(t);
  }
}
