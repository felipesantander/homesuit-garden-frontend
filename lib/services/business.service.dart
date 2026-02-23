import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:garden_homesuit/models/business.model.dart';
import 'package:garden_homesuit/services/base_api.service.dart';

class BusinessService {
  final Dio _dio;

  BusinessService({required String token, VoidCallback? onUnauthorized})
    : _dio = createDio(token, onUnauthorized: onUnauthorized);

  /// GET /api/businesses/
  Future<List<Business>> fetchAll() async {
    final response = await _dio.get('/api/businesses/');
    return (response.data as List)
        .map((json) => Business.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// POST /api/businesses/
  Future<Business> create({required String name}) async {
    final response = await _dio.post('/api/businesses/', data: {'name': name});
    return Business.fromJson(response.data as Map<String, dynamic>);
  }

  /// GET /api/businesses/`{businessId}`/
  Future<Business> fetchById(String id) async {
    final response = await _dio.get('/api/businesses/$id/');
    return Business.fromJson(response.data as Map<String, dynamic>);
  }

  /// PATCH /api/businesses/`{businessId}`/
  Future<Business> update(String id, Map<String, dynamic> data) async {
    final response = await _dio.patch('/api/businesses/$id/', data: data);
    return Business.fromJson(response.data as Map<String, dynamic>);
  }

  /// DELETE /api/businesses/`{businessId}`/
  Future<void> delete(String id) async {
    await _dio.delete('/api/businesses/$id/');
  }
}
