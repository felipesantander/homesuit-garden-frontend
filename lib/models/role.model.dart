class Role {
  final String idRole;
  final String name;
  final List<String> permissions;

  Role({required this.idRole, required this.name, this.permissions = const []});

  factory Role.fromJson(Map<String, dynamic> json) {
    final rawId = json['idRole'] ?? json['id_role'] ?? json['uuid'];

    return Role(
      idRole: rawId?.toString() ?? '',
      name: json['name'] as String? ?? 'Sin Nombre',
      permissions: (json['permissions'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'idRole': idRole, 'name': name, 'permissions': permissions};
  }
}
