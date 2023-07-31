import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class Net {
  Net._();

  static late final Dio _dio;

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
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) =>
      _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

  static Future<Response<T>> get<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) =>
      _dio.get(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
}
