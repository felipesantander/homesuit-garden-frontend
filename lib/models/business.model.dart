class Business {
  final String idBusiness;
  final String name;

  Business({required this.idBusiness, required this.name});

  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
      idBusiness: json['idBusiness'].toString(),
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'idBusiness': idBusiness, 'name': name};
  }
}
