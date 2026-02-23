import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:garden_homesuit/models/auth_response.model.dart';
import 'package:garden_homesuit/services/auth.service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hooks_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

final authServiceProvider = Provider((ref) => AuthService());

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthResponse?>(
  (ref) => AuthNotifier(ref),
);

class AuthNotifier extends StateNotifier<AuthResponse?> {
  static const String _authKey = 'auth_state';

  AuthNotifier(this._ref) : super(null) {
    _loadAuthState();
  }

  final Ref _ref;

  Future<void> _loadAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    final authJson = prefs.getString(_authKey);

    if (authJson != null) {
      try {
        final authData = jsonDecode(authJson) as Map<String, dynamic>;
        state = AuthResponse.fromJson(authData);
      } catch (e) {
        // Si hay error al decodificar, limpiar el estado
        await prefs.remove(_authKey);
      }
    }
  }

  Future<void> setAuthState(AuthResponse response) async {
    state = response;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authKey, jsonEncode(response.toJson()));
  }

  Future<void> clearAuthState() async {
    state = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authKey);
  }

  /// Refresh the access token using the stored refresh token
  Future<void> refreshAccessToken() async {
    final currentState = state;
    if (currentState == null) return;

    try {
      final service = _ref.read(authServiceProvider);
      final newAccess = await service.refreshToken(currentState.refresh);
      final updatedState = AuthResponse(
        access: newAccess,
        refresh: currentState.refresh,
      );
      await setAuthState(updatedState);
    } catch (e) {
      debugPrint('Error refreshing token: $e');
      await clearAuthState();
    }
  }
}

final loginActionProvider = Provider((ref) {
  return ({required String username, required String password}) async {
    final service = ref.read(authServiceProvider);

    final response = await service.login(
      username: username,
      password: password,
    );

    // Guardar el estado de autenticación en memoria y persistencia
    await ref.read(authStateProvider.notifier).setAuthState(response);

    return response;
  };
});

final logoutActionProvider = Provider((ref) {
  return () async {
    await ref.read(authStateProvider.notifier).clearAuthState();
  };
});
