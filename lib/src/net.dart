import 'dart:async';
import 'dart:convert';

import 'package:base/base.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class Net {
  Net._();

  static late final Dio _dio;

  static CancelToken _cancel = CancelToken();

  static final Broadcast<ConnectivityResult> _connectCtrl = Broadcast(ConnectivityResult.none);

  static void logout() {
    _cancel.cancel();
    _cancel = CancelToken();
  }

  static Future<void> init({
    List<Interceptor>? interceptors,
  }) async {
    // http
    _dio = Dio()
      ..interceptors.addAll(interceptors ?? [])
      ..options = BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      )
      ..transformer = SyncTransformer(
        jsonDecodeCallback: (s) => compute(jsonDecode, s),
      );
    // connect
    Connectivity c = Connectivity();
    ConnectivityResult r = await c.checkConnectivity();
    _connectCtrl.add(r);
    c.onConnectivityChanged.listen((r) => _connectCtrl.add(r));
  }

  static Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
  }) =>
      _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken ?? _cancel,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

  static Future<Response<T>> get<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
  }) =>
      _dio.get<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken ?? _cancel,
        onReceiveProgress: onReceiveProgress,
      );

  Stream<ConnectivityResult> connect() => _connectCtrl.stream().distinct();

  ConnectivityResult connectivity() => _connectCtrl.value();
}
