import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:garden_homesuit/models/permission.model.dart';
import 'package:garden_homesuit/services/base_api.service.dart';

class PermissionsService {
  final Dio _dio;

  PermissionsService({required String token, VoidCallback? onUnauthorized})
    : _dio = createDio(token, onUnauthorized: onUnauthorized);

  Future<List<Permission>> fetchAll() async {
    final response = await _dio.get('/api/permissions/');
    return (response.data as List)
        .map((json) => Permission.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<Permission> create(Map<String, dynamic> data) async {
    final response = await _dio.post('/api/permissions/', data: data);
    return Permission.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Permission> fetchById(String idPermission) async {
    final response = await _dio.get('/api/permissions/$idPermission/');
    return Permission.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Permission> update(
    String idPermission,
    Map<String, dynamic> data,
  ) async {
    final response = await _dio.put(
      '/api/permissions/$idPermission/',
      data: data,
    );
    return Permission.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Permission> patch(
    String idPermission,
    Map<String, dynamic> data,
  ) async {
    final response = await _dio.patch(
      '/api/permissions/$idPermission/',
      data: data,
    );
    return Permission.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> delete(String idPermission) async {
    await _dio.delete('/api/permissions/$idPermission/');
  }
}
