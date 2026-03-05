import 'package:jwt_decoder/jwt_decoder.dart';

class AuthResponse {
  final String access;
  final String refresh;
  final List<String> components;

  AuthResponse({
    required this.access,
    required this.refresh,
    this.components = const [],
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final access = json['access']?.toString() ?? '';
    final refresh = json['refresh']?.toString() ?? '';

    List<String> extractedComponents = [];
    if (access.isNotEmpty) {
      try {
        final Map<String, dynamic> decodedToken = JwtDecoder.decode(access);
        final rawComponents = decodedToken['components'];
        if (rawComponents is List) {
          extractedComponents = rawComponents.map((e) => e.toString()).toList();
        }
      } catch (e) {
        // En caso de que el token no sea un JWT válido o no tenga componentes
      }
    }

    return AuthResponse(
      access: access,
      refresh: refresh,
      components: extractedComponents,
    );
  }

  Map<String, dynamic> toJson() {
    return {'access': access, 'refresh': refresh, 'components': components};
  }
}
