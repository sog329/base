import 'dart:async';
import 'dart:convert';

import 'package:base/base.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class Net {
  Net._();

  static late final Dio _dio;

  static CancelToken _cancel = CancelToken();

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
          sendTimeout: const Duration(seconds: 10),
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
}