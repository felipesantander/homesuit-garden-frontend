class Channel {
  final String idChannel;
  final String name;
  final String? business;
  final String unit;
  final String color;
  final String icon;

  Channel({
    required this.idChannel,
    required this.name,
    required this.unit,
    this.business,
    this.color = '#9EA7B8',
    this.icon = '',
  });

  factory Channel.fromJson(Map<String, dynamic> json) {
    return Channel(
      idChannel: json['idChannel']?.toString() ?? '',
      name: (json['name'] ?? json['Name'])?.toString() ?? '',
      unit: (json['unit'] ?? json['Unit'])?.toString() ?? '',
      business: json['business']?.toString(),
      color: json['color']?.toString() ?? '#9EA7B8',
      icon: json['icon']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idChannel': idChannel,
      'name': name,
      'unit': unit,
      'business': business,
      'color': color,
      'icon': icon,
    };
  }
}
