import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:garden_homesuit/services/base_api.service.dart';

class ConfigurationChannelService {
  final Dio _dio;

  ConfigurationChannelService({
    required String token,
    VoidCallback? onUnauthorized,
  }) : _dio = createDio(token, onUnauthorized: onUnauthorized);

  /// GET /api/configuration-channels/
  Future<List<Map<String, dynamic>>> fetchAll() async {
    final response = await _dio.get('/api/configuration-channels/');
    return (response.data as List)
        .map((json) => json as Map<String, dynamic>)
        .toList();
  }

  /// POST /api/configuration-channels/
  Future<Map<String, dynamic>> create({
    required String machineId,
    required String type,
    required String channelId,
    required String serial,
  }) async {
    final Map<String, dynamic> data = {
      'machine': machineId,
      'type': type,
      'channel': channelId,
      'serial': serial,
    };

    final response = await _dio.post(
      '/api/configuration-channels/',
      data: data,
    );
    return response.data as Map<String, dynamic>;
  }

  /// GET /api/configuration-channels/{uuid}/
  Future<Map<String, dynamic>> fetchById(String uuid) async {
    final response = await _dio.get('/api/configuration-channels/$uuid/');
    return response.data as Map<String, dynamic>;
  }

  /// PUT /api/configuration-channels/{uuid}/
  Future<Map<String, dynamic>> update(
    String uuid,
    Map<String, dynamic> data,
  ) async {
    final response = await _dio.put(
      '/api/configuration-channels/$uuid/',
      data: data,
    );
    return response.data as Map<String, dynamic>;
  }

  /// PATCH /api/configuration-channels/{uuid}/
  Future<Map<String, dynamic>> patch(
    String uuid,
    Map<String, dynamic> data,
  ) async {
    final response = await _dio.patch(
      '/api/configuration-channels/$uuid/',
      data: data,
    );
    return response.data as Map<String, dynamic>;
  }

  /// DELETE /api/configuration-channels/{uuid}/
  Future<void> delete(String uuid) async {
    await _dio.delete('/api/configuration-channels/$uuid/');
  }
}
