import 'dart:async';
import 'dart:convert';

import 'package:base/base.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class Net {
  Net._();

  static late final Dio _dio;

  static CancelToken _cancel = CancelToken();

  // todo https://vimsky.com/examples/usage/dart-async-Future-catchError-da.html
  // todo https://github.com/cfug/dio/blob/main/dio/README-ZH.md
  static final Function _onError = (err) {
    if(CancelToken.isCancel(err)){
      HpDevice.log('s');
    }
  };

  static void logout() {
    _cancel.cancel();
    _cancel = CancelToken();
  }

  static void init({
    List<Interceptor>? interceptors,
  }) =>
      _dio = Dio()
        ..interceptors.addAll(interceptors ?? [])
        ..options = BaseOptions(
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        )
        ..transformer = SyncTransformer(
          jsonDecodeCallback: (s) => compute(jsonDecode, s),
        );

  static Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) =>
      _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: _cancel,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

  static Future<Response<T>> get<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    ProgressCallback? onReceiveProgress,
  }) =>
      _dio
          .get<T>(
            path,
            data: data,
            queryParameters: queryParameters,
            options: options,
            cancelToken: _cancel,
            onReceiveProgress: onReceiveProgress,
          )
          .catchError(_onError);
}
