import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:garden_homesuit/models/notification.model.dart';
import 'package:garden_homesuit/services/base_api.service.dart';

class NotificationService {
  final Dio _dio;

  NotificationService({required String token, VoidCallback? onUnauthorized})
    : _dio = createDio(token, onUnauthorized: onUnauthorized);

  /// GET /api/notifications/
  Future<List<AppNotification>> fetchAll() async {
    final response = await _dio.get('/api/notifications/');
    return (response.data as List)
        .map((json) => AppNotification.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// PATCH /api/notifications/`{id}`/ - Mark as seen
  Future<AppNotification> markAsSeen(String id) async {
    final response = await _dio.patch(
      '/api/notifications/$id/',
      data: {'seen': true},
    );
    return AppNotification.fromJson(response.data as Map<String, dynamic>);
  }
}
