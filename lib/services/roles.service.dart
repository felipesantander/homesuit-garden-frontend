import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:garden_homesuit/models/role.model.dart';
import 'package:garden_homesuit/services/base_api.service.dart';

class RolesService {
  final Dio _dio;

  RolesService({required String token, VoidCallback? onUnauthorized})
    : _dio = createDio(token, onUnauthorized: onUnauthorized);

  Future<List<Role>> fetchAll() async {
    final response = await _dio.get('/api/roles/');
    return (response.data as List)
        .map((json) => Role.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<Role> create(Map<String, dynamic> data) async {
    final response = await _dio.post('/api/roles/', data: data);
    return Role.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Role> fetchById(String idRole) async {
    final response = await _dio.get('/api/roles/$idRole/');
    return Role.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Role> update(String idRole, Map<String, dynamic> data) async {
    final response = await _dio.put('/api/roles/$idRole/', data: data);
    return Role.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Role> patch(String idRole, Map<String, dynamic> data) async {
    final response = await _dio.patch('/api/roles/$idRole/', data: data);
    return Role.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> delete(String idRole) async {
    await _dio.delete('/api/roles/$idRole/');
  }
}
