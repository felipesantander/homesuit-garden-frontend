class Garden {
  final String idGarden;
  final String name;
  final String business;

  Garden({required this.idGarden, required this.name, required this.business});

  factory Garden.fromJson(Map<String, dynamic> json) {
    return Garden(
      idGarden: json['idGarden']?.toString() ?? '',
      name: (json['name'] ?? json['Name'])?.toString() ?? '',
      business: (json['business'] ?? json['idBusiness'])?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'idGarden': idGarden, 'name': name, 'business': business};
  }
}
