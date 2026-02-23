import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:garden_homesuit/models/garden.model.dart';
import 'package:garden_homesuit/services/base_api.service.dart';

class GardenService {
  final Dio _dio;

  GardenService({required String token, VoidCallback? onUnauthorized})
    : _dio = createDio(token, onUnauthorized: onUnauthorized);

  /// GET /api/gardens/
  Future<List<Garden>> fetchAll() async {
    final response = await _dio.get('/api/gardens/');
    final List<dynamic> data = response.data as List<dynamic>;
    return data
        .map((json) => Garden.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// POST /api/gardens/
  Future<Garden> create(Map<String, dynamic> data) async {
    final response = await _dio.post('/api/gardens/', data: data);
    return Garden.fromJson(response.data as Map<String, dynamic>);
  }

  /// GET /api/gardens/`{id}`/
  Future<Garden> fetchById(String id) async {
    final response = await _dio.get('/api/gardens/$id/');
    return Garden.fromJson(response.data as Map<String, dynamic>);
  }

  /// PATCH /api/gardens/`{id}`/
  Future<Garden> update(String id, Map<String, dynamic> data) async {
    final response = await _dio.patch('/api/gardens/$id/', data: data);
    return Garden.fromJson(response.data as Map<String, dynamic>);
  }

  /// DELETE /api/gardens/`{id}`/
  Future<void> delete(String id) async {
    await _dio.delete('/api/gardens/$id/');
  }
}
