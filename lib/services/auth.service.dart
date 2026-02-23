import 'package:dio/dio.dart';
import 'package:garden_homesuit/config/services.config.dart';
import 'package:garden_homesuit/models/auth_response.model.dart';

class AuthService {
  final Dio _dio;

  AuthService()
    : _dio = Dio(
        BaseOptions(
          baseUrl: urlApi.startsWith('http') ? urlApi : 'http://$urlApi',
        ),
      );

  /// Login with username and password
  /// POST /api/token/
  Future<AuthResponse> login({
    required String username,
    required String password,
  }) async {
    final response = await _dio.post(
      '/api/token/',
      data: {'username': username, 'password': password},
    );

    if (response.statusCode == 200) {
      return AuthResponse.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw Exception('Failed to login: ${response.statusCode}');
    }
  }

  /// Refresh access token
  /// POST /api/token/refresh/
  Future<String> refreshToken(String refresh) async {
    final response = await _dio.post(
      '/api/token/refresh/',
      data: {'refresh': refresh},
    );

    if (response.statusCode == 200) {
      return response.data['access'] as String;
    } else {
      throw Exception('Failed to refresh token: ${response.statusCode}');
    }
  }

  /// Verify if a token is valid
  /// POST /api/token/verify/
  Future<bool> verifyToken(String token) async {
    try {
      final response = await _dio.post(
        '/api/token/verify/',
        data: {'token': token},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
