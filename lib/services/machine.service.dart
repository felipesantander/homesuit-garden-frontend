import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:garden_homesuit/models/machine.model.dart';
import 'package:garden_homesuit/services/base_api.service.dart';

class MachineService {
  final Dio _dio;

  MachineService({required String token, VoidCallback? onUnauthorized})
    : _dio = createDio(token, onUnauthorized: onUnauthorized);

  /// GET /api/machines/
  Future<List<Machine>> fetchAll() async {
    final response = await _dio.get('/api/machines/');
    return (response.data as List)
        .map((json) => Machine.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// POST /api/machines/
  Future<Machine> create({
    required String serial,
    required String name,
    String? gardenId,
    Map<String, String>? channelMappings,
  }) async {
    final Map<String, dynamic> data = {
      'serial': serial,
      'Name': name,
      'garden': gardenId,
      'channel_mappings': channelMappings,
    };

    final response = await _dio.post('/api/machines/', data: data);
    return Machine.fromJson(response.data as Map<String, dynamic>);
  }

  /// GET /api/machines/`{machineId}`/
  Future<Machine> fetchById(String machineId) async {
    final response = await _dio.get('/api/machines/$machineId/');
    return Machine.fromJson(response.data as Map<String, dynamic>);
  }

  /// PATCH /api/machines/`{machineId}`/
  Future<Machine> update(String machineId, Map<String, dynamic> data) async {
    final response = await _dio.patch('/api/machines/$machineId/', data: data);
    return Machine.fromJson(response.data as Map<String, dynamic>);
  }

  /// DELETE /api/machines/`{machineId}`/
  Future<void> delete(String machineId) async {
    await _dio.delete('/api/machines/$machineId/');
  }

  /// POST /api/machines/register/
  Future<Machine> register({
    required String serial,
    required String name,
    required List<String> supportedFrequencies,
    required String dashboardFrequency,
    String? gardenId,
    List<Map<String, String>>? configurations,
  }) async {
    final Map<String, dynamic> data = {
      'serial': serial,
      'Name': name,
      'garden': gardenId,
      'supported_frequencies': supportedFrequencies,
      'dashboard_frequency': dashboardFrequency,
      'configurations': configurations,
    };

    final response = await _dio.post('/api/machines/register/', data: data);
    return Machine.fromJson(response.data as Map<String, dynamic>);
  }
}
