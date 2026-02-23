class Machine {
  final String id;
  final String serial;
  final String name;
  final String? garden;
  final Map<String, String>? channelMappings;
  final List<String> supportedFrequencies;
  final String? dashboardFrequency;

  Machine({
    required this.id,
    required this.serial,
    required this.name,
    this.garden,
    this.channelMappings,
    this.supportedFrequencies = const [],
    this.dashboardFrequency,
  });

  factory Machine.fromJson(Map<String, dynamic> json) {
    // Robust ID parsing
    final rawId =
        json['id'] ??
        json['idMachine'] ??
        json['id_machine'] ??
        json['machineId'] ??
        json['machine_id'] ??
        json['uuid'];

    return Machine(
      id: rawId?.toString() ?? '',
      serial: json['serial'] as String? ?? 'Desconocido',
      name: (json['Name'] ?? json['name']) as String? ?? 'Nodo sin nombre',
      garden: json['garden']?.toString(),
      channelMappings: json['channel_mappings'] != null
          ? Map<String, String>.from(json['channel_mappings'] as Map)
          : null,
      supportedFrequencies: (json['supported_frequencies'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),
      dashboardFrequency:
          (json['dashboardFrequency'] ?? json['dashboard_frequency'])
              as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serial': serial,
      'Name': name,
      'garden': garden,
      'channel_mappings': channelMappings,
      'supported_frequencies': supportedFrequencies,
      'dashboard_frequency': dashboardFrequency,
    };
  }
}
