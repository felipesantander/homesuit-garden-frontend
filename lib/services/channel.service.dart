import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:garden_homesuit/models/channel.model.dart';
import 'package:garden_homesuit/services/base_api.service.dart';

class ChannelService {
  final Dio _dio;

  ChannelService({required String token, VoidCallback? onUnauthorized})
    : _dio = createDio(token, onUnauthorized: onUnauthorized);

  /// GET /api/channels/
  Future<List<Channel>> fetchAll() async {
    final response = await _dio.get('/api/channels/');
    return (response.data as List)
        .map((json) => Channel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// POST /api/channels/
  Future<Channel> create({
    required String name,
    required String unit,
    String? business,
  }) async {
    final response = await _dio.post(
      '/api/channels/',
      data: {'name': name, 'unit': unit, 'business': business},
    );
    return Channel.fromJson(response.data as Map<String, dynamic>);
  }

  /// GET /api/channels/`{channelId}`/
  Future<Channel> fetchById(String id) async {
    final response = await _dio.get('/api/channels/$id/');
    return Channel.fromJson(response.data as Map<String, dynamic>);
  }

  /// PATCH /api/channels/`{channelId}`/
  Future<Channel> update(String id, Map<String, dynamic> data) async {
    final response = await _dio.patch('/api/channels/$id/', data: data);
    return Channel.fromJson(response.data as Map<String, dynamic>);
  }

  /// DELETE /api/channels/`{channelId}`/
  Future<void> delete(String id) async {
    await _dio.delete('/api/channels/$id/');
  }
}
