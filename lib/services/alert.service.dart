import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/alert.model.dart';
import '../models/alert_history.model.dart';
import 'base_api.service.dart';

class AlertService {
  final Dio _dio;

  AlertService({required String token, VoidCallback? onUnauthorized})
    : _dio = createDio(token, onUnauthorized: onUnauthorized);

  Future<List<Alert>> getAlerts() async {
    final response = await _dio.get('/api/alerts/');
    final List data = response.data;
    return data.map((json) => Alert.fromJson(json)).toList();
  }

  Future<Alert> getAlert(String id) async {
    final response = await _dio.get('/api/alerts/$id/');
    return Alert.fromJson(response.data);
  }

  Future<Alert> createAlert(Alert alert) async {
    final response = await _dio.post('/api/alerts/', data: alert.toJson());
    return Alert.fromJson(response.data);
  }

  Future<Alert> updateAlert(String id, Map<String, dynamic> data) async {
    if (id.isEmpty) {
      throw Exception("ID de alerta no encontrado. No se puede actualizar.");
    }
    final response = await _dio.patch('/api/alerts/$id/', data: data);
    return Alert.fromJson(response.data);
  }

  Future<void> deleteAlert(String id) async {
    if (id.isEmpty) {
      throw Exception("ID de alerta no encontrado. No se puede eliminar.");
    }
    await _dio.delete('/api/alerts/$id/');
  }

  Future<List<AlertHistory>> getAlertHistory() async {
    final response = await _dio.get('/api/alert-history/');
    final List data = response.data;
    return data.map((json) => AlertHistory.fromJson(json)).toList();
  }

  Future<AlertHistory> getAlertHistoryDetail(String id) async {
    final response = await _dio.get('/api/alert-history/$id/');
    return AlertHistory.fromJson(response.data);
  }
}
