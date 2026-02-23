class PermissionEndpoint {
  final String path;
  final String host;
  final String method;

  PermissionEndpoint({
    required this.path,
    required this.host,
    required this.method,
  });

  factory PermissionEndpoint.fromJson(Map<String, dynamic> json) {
    return PermissionEndpoint(
      path: json['path'] as String? ?? '',
      host: json['host'] as String? ?? '',
      method: json['method'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'path': path, 'host': host, 'method': method};
  }
}

class Permission {
  final String idPermission;
  final String name;
  final List<PermissionEndpoint> endpoints;
  final List<String> channels;
  final List<String> machines;
  final List<String> gardens;
  final List<String> businesses;
  final List<String> components;

  Permission({
    required this.idPermission,
    required this.name,
    this.endpoints = const [],
    this.channels = const [],
    this.machines = const [],
    this.gardens = const [],
    this.businesses = const [],
    this.components = const [],
  });

  factory Permission.fromJson(Map<String, dynamic> json) {
    final rawId = json['idPermission'] ?? json['id_permission'] ?? json['uuid'];

    return Permission(
      idPermission: rawId?.toString() ?? '',
      name: json['name'] as String? ?? 'Sin Nombre',
      endpoints: (json['endpoints'] as List<dynamic>? ?? [])
          .map((e) => PermissionEndpoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      channels: (json['channels'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      machines: (json['machines'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      gardens: (json['gardens'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      businesses: (json['businesses'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      components: (json['components'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idPermission': idPermission,
      'name': name,
      'endpoints': endpoints.map((e) => e.toJson()).toList(),
      'channels': channels,
      'machines': machines,
      'gardens': gardens,
      'businesses': businesses,
      'components': components,
    };
  }
}
