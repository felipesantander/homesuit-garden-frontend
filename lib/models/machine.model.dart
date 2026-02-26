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
      channelMappings: _parseMappings(
        json['channel_mappings'] ?? json['configurations'],
      ),
      supportedFrequencies: (json['supported_frequencies'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),
      dashboardFrequency:
          (json['dashboardFrequency'] ?? json['dashboard_frequency'])
              as String?,
    );
  }

  static Map<String, String>? _parseMappings(dynamic raw) {
    if (raw == null) return null;
    if (raw is Map) {
      return Map<String, String>.from(
        raw.map((k, v) => MapEntry(k.toString(), v.toString())),
      );
    }
    if (raw is List) {
      final Map<String, String> mappings = {};
      for (final item in raw) {
        if (item is Map) {
          final type = item['type']?.toString();
          var channelRaw =
              item['channel'] ?? item['idChannel'] ?? item['id_channel'];

          if (channelRaw is Map) {
            channelRaw =
                channelRaw['idChannel'] ??
                channelRaw['id_channel'] ??
                channelRaw['id'] ??
                channelRaw['uuid'];
          }

          final channelId = channelRaw?.toString();
          if (type != null && channelId != null) {
            mappings[type] = channelId;
          }
        }
      }
      return mappings.isNotEmpty ? mappings : null;
    }
    return null;
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
