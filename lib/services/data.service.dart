import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:garden_homesuit/models/data_bucket.model.dart';
import 'package:garden_homesuit/services/base_api.service.dart';

class DataService {
  final Dio _dio;

  DataService({required String token, VoidCallback? onUnauthorized})
    : _dio = createDio(token, onUnauthorized: onUnauthorized);

  /// GET /api/data/
  Future<List<DataBucket>> fetchAll() async {
    final response = await _dio.get('/api/data/');
    return (response.data as List)
        .map((json) => DataBucket.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// GET /api/data/latest/?serial=SERIAL
  Future<Map<String, dynamic>> fetchLatestBySerial(String serial) async {
    final response = await _dio.get(
      '/api/data/latest/',
      queryParameters: {'serial': serial},
    );
    return response.data as Map<String, dynamic>;
  }

  /// GET /api/data/?serial=SERIAL
  Future<List<DataBucket>> fetchHistoryBySerial(String serial) async {
    final response = await _dio.get(
      '/api/data/',
      queryParameters: {'serial': serial},
    );
    return (response.data as List)
        .map((json) => DataBucket.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// GET /api/data-buckets/`{id}`/
  Future<DataBucket> fetchById(String id) async {
    final response = await _dio.get('/api/data/$id/');
    return DataBucket.fromJson(response.data as Map<String, dynamic>);
  }

  /// GET /api/data/query/
  Future<List<Map<String, dynamic>>> query({
    required String machineId,
    String? channels,
    String? start,
    String? end,
    String? f,
    int? limit,
  }) async {
    final response = await _dio.get(
      '/api/data/query/',
      queryParameters: {
        'machineId': machineId,
        'channels': channels,
        'start': start,
        'end': end,
        'f': f,
        'limit': limit,
      }..removeWhere((key, value) => value == null),
    );
    return (response.data as List)
        .map((e) => e as Map<String, dynamic>)
        .toList();
  }

  /// DELETE /api/data-buckets/`{id}`/
  Future<void> delete(String id) async {
    await _dio.delete('/api/data/$id/');
  }

  /// POST /api/ingest/ (unprotected)
  Future<void> ingestData({
    required String frequency,
    required double value,
    required String type,
    required String serialMachine,
    required String machineId,
    required String channelId,
    String? dateOfCapture,
  }) async {
    // Ingest endpoint uses a separate Dio instance (no auth required)
    final ingestDio = Dio(BaseOptions(baseUrl: _dio.options.baseUrl));

    await ingestDio.post(
      '/api/ingest/',
      data: {
        'frequency': frequency,
        'value': value,
        'type': type,
        'serial_machine': serialMachine,
        'machineId': machineId,
        'channelId': channelId,
        'date_of_capture': dateOfCapture,
      },
    );
  }
}
