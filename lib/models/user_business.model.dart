class UserBusiness {
  final String idUserBusiness;
  final int user;
  final String business;

  UserBusiness({
    required this.idUserBusiness,
    required this.user,
    required this.business,
  });

  factory UserBusiness.fromJson(Map<String, dynamic> json) {
    return UserBusiness(
      idUserBusiness: json['idUserBusiness'] as String? ?? '',
      user: json['user'] as int? ?? 0,
      business: json['business'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idUserBusiness': idUserBusiness,
      'user': user,
      'business': business,
    };
  }
}
