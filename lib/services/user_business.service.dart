import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:garden_homesuit/services/base_api.service.dart';
import 'package:garden_homesuit/models/user_business.model.dart';
import 'package:garden_homesuit/providers/auth.provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final userBusinessServiceProvider = Provider<UserBusinessService>((ref) {
  final authState = ref.watch(authStateProvider);
  return UserBusinessService(
    token: authState?.access ?? '',
    onUnauthorized: () => ref.read(authStateProvider.notifier).clearAuthState(),
  );
});

class UserBusinessService {
  final Dio _dio;

  UserBusinessService({required String token, VoidCallback? onUnauthorized})
    : _dio = createDio(token, onUnauthorized: onUnauthorized);

  Future<UserBusiness> getUserBusiness(String id) async {
    final response = await _dio.get('/api/user-businesses/$id/');
    return UserBusiness.fromJson(response.data as Map<String, dynamic>);
  }

  Future<UserBusiness> createUserBusiness({
    required int userId,
    required String businessId,
  }) async {
    final response = await _dio.post(
      '/api/user-businesses/',
      data: {'user': userId, 'business': businessId},
    );
    return UserBusiness.fromJson(response.data as Map<String, dynamic>);
  }

  Future<UserBusiness> updateUserBusiness(
    String id, {
    required String newBusinessId,
  }) async {
    final response = await _dio.patch(
      '/api/user-businesses/$id/',
      data: {'business': newBusinessId},
    );
    return UserBusiness.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteUserBusiness(String id) async {
    await _dio.delete('/api/user-businesses/$id/');
  }
}
