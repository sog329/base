import 'dart:async';

import 'package:flutter/cupertino.dart';

class StreamWidget<T> extends StreamBuilder<T> {
  StreamWidget({
    super.key,
    required super.stream,
    super.initialData,
    required Widget Function(
      BuildContext ctx,
      AsyncSnapshot<T> snapshot,
      Widget? child,
    ) builder,
    Widget? child,
  }) : super(
          builder: (c, s) => builder.call(c, s, child),
        );
}
