import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:garden_homesuit/models/machine_candidate.model.dart';
import 'package:garden_homesuit/services/base_api.service.dart';

class MachineCandidateService {
  final Dio _dio;

  MachineCandidateService({required String token, VoidCallback? onUnauthorized})
    : _dio = createDio(token, onUnauthorized: onUnauthorized);

  /// GET /api/machine-candidates/
  Future<List<MachineCandidate>> fetchAll() async {
    final response = await _dio.get('/api/machine-candidates/');
    return (response.data as List)
        .map((json) => MachineCandidate.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// POST /api/machine-candidates/
  Future<MachineCandidate> create(Map<String, dynamic> data) async {
    final response = await _dio.post('/api/machine-candidates/', data: data);
    return MachineCandidate.fromJson(response.data as Map<String, dynamic>);
  }

  /// GET /api/machine-candidates/`{id}`/
  Future<MachineCandidate> fetchById(String id) async {
    final response = await _dio.get('/api/machine-candidates/$id/');
    return MachineCandidate.fromJson(response.data as Map<String, dynamic>);
  }

  /// PATCH /api/machine-candidates/`{id}`/
  Future<MachineCandidate> update(String id, Map<String, dynamic> data) async {
    final response = await _dio.patch(
      '/api/machine-candidates/$id/',
      data: data,
    );
    return MachineCandidate.fromJson(response.data as Map<String, dynamic>);
  }

  /// DELETE /api/machine-candidates/`{id}`/
  Future<void> delete(String id) async {
    await _dio.delete('/api/machine-candidates/$id/');
  }
}
