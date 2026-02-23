class Channel {
  final String idChannel;
  final String name;
  final String? business;
  final String unit;

  Channel({
    required this.idChannel,
    required this.name,
    required this.unit,
    this.business,
  });

  factory Channel.fromJson(Map<String, dynamic> json) {
    return Channel(
      idChannel: json['idChannel'].toString(),
      name: json['name'] as String,
      unit: json['unit'] as String? ?? '',
      business: json['business']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idChannel': idChannel,
      'name': name,
      'unit': unit,
      'business': business,
    };
  }
}
