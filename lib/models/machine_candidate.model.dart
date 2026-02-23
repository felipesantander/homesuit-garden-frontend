class MachineCandidate {
  final String id;
  final String serial;
  final List<String> types;
  final String? business;
  final DateTime? discoveredAt;

  MachineCandidate({
    required this.id,
    required this.serial,
    required this.types,
    this.business,
    this.discoveredAt,
  });

  factory MachineCandidate.fromJson(Map<String, dynamic> json) {
    return MachineCandidate(
      id: json['id'] as String,
      serial: json['serial'] as String,
      types: (json['types'] as List? ?? []).map((e) => e.toString()).toList(),
      business: json['business']?.toString(),
      discoveredAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serial': serial,
      'types': types,
      'business': business,
      'discovered_at': discoveredAt?.toIso8601String(),
    };
  }
}
