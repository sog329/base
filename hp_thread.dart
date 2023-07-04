import 'dart:async';
import 'dart:isolate';

import 'package:anim_studio/base/hp_platform.dart';
import 'package:async/async.dart';
import 'package:flutter/foundation.dart';

class HpThread {
  HpThread._();

  /// compute 仅支持简单类型传递计算
  static Future<R> async<O, R>({
    required O o,
    required R Function(O o) w,
  }) =>
      compute(w, o);

  static String? current() => HpPlatform.isWeb() ? null : Isolate.current.debugName;

  // 可取消任务
  static CancelableOperation<T> syncCancelable<T>(
    Future<T> f, [
    FutureOr Function()? onCancel,
  ]) =>
      CancelableOperation.fromFuture(
        f,
        onCancel: onCancel,
      );
}
