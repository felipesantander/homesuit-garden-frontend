import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:garden_homesuit/config/services.config.dart';

Dio createDio(String token, {VoidCallback? onUnauthorized}) {
  final dio = Dio(
    BaseOptions(baseUrl: urlApi, headers: {'Authorization': 'Bearer $token'}),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          onUnauthorized?.call();
        }
        return handler.next(error);
      },
    ),
  );
  return dio;
}
