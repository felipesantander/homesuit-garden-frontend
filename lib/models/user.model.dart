class UserModel {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String? roleName;
  final List<String> idUserBusinesses;
  final List<String> businessIds;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.roleName,
    this.idUserBusinesses = const [],
    this.businessIds = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    String? parsedRole;
    if (json['role_name'] != null) {
      parsedRole = json['role_name'] as String;
    } else if (json['groups'] != null && (json['groups'] as List).isNotEmpty) {
      final groups = json['groups'] as List;
      parsedRole = groups[0]['name'] as String?;
    }

    // Safely parse lists, handling possible nulls
    List<String> parsedIdUserBusinesses = [];
    if (json['idUserBusinesses'] != null) {
      parsedIdUserBusinesses = List<String>.from(json['idUserBusinesses']);
    } else if (json['idUserBusiness'] != null) {
      // Fallback for previous single item property
      parsedIdUserBusinesses.add(json['idUserBusiness'].toString());
    }

    List<String> parsedBusinessIds = [];
    if (json['businessIds'] != null) {
      parsedBusinessIds = List<String>.from(json['businessIds']);
    } else if (json['businessId'] != null) {
      // Fallback for previous single item property
      parsedBusinessIds.add(json['businessId'].toString());
    }

    return UserModel(
      id: json['id'] as int,
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      roleName: parsedRole,
      idUserBusinesses: parsedIdUserBusinesses,
      businessIds: parsedBusinessIds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      if (roleName != null) 'role_name': roleName,
      if (idUserBusinesses.isNotEmpty) 'idUserBusinesses': idUserBusinesses,
      if (businessIds.isNotEmpty) 'businessIds': businessIds,
    };
  }

  UserModel copyWith({
    int? id,
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    String? roleName,
    List<String>? idUserBusinesses,
    List<String>? businessIds,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      roleName: roleName ?? this.roleName,
      idUserBusinesses: idUserBusinesses ?? this.idUserBusinesses,
      businessIds: businessIds ?? this.businessIds,
    );
  }
}
