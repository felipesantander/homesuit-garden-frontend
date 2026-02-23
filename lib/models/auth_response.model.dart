class AuthResponse {
  final String access;
  final String refresh;

  AuthResponse({required this.access, required this.refresh});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      access: json['access'] as String,
      refresh: json['refresh'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'access': access, 'refresh': refresh};
  }
}
