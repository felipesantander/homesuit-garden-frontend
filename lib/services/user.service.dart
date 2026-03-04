import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:garden_homesuit/services/base_api.service.dart';
import 'package:garden_homesuit/models/user.model.dart';
import 'package:garden_homesuit/providers/auth.provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final userServiceProvider = Provider<UserService>((ref) {
  final authState = ref.watch(authStateProvider);
  return UserService(
    token: authState?.access ?? '',
    onUnauthorized: () => ref.read(authStateProvider.notifier).clearAuthState(),
  );
});

class UserService {
  final Dio _dio;

  UserService({required String token, VoidCallback? onUnauthorized})
    : _dio = createDio(token, onUnauthorized: onUnauthorized);

  Future<List<UserModel>> getUsers({int page = 1}) async {
    final response = await _dio.get(
      '/api/users/',
      queryParameters: {'page': page},
    );

    if (response.data is Map<String, dynamic> &&
        response.data.containsKey('results')) {
      final List<dynamic> results = response.data['results'];
      return results
          .map((json) => UserModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }

    if (response.data is List) {
      return (response.data as List)
          .map((json) => UserModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<UserModel> getUser(int id) async {
    final response = await _dio.get('/api/users/$id/');
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<UserModel> createUser(Map<String, dynamic> data) async {
    final response = await _dio.post('/api/users/', data: data);
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<UserModel> updateUser(int id, Map<String, dynamic> data) async {
    final response = await _dio.patch('/api/users/$id/', data: data);
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteUser(int id) async {
    await _dio.delete('/api/users/$id/');
  }

  Future<void> assignRole(int userId, String roleId) async {
    await _dio.post(
      '/api/users/$userId/assign_role/',
      data: {'role_id': roleId},
    );
  }
}
