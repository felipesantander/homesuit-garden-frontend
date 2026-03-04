class Alert {
  final String id;
  final String name;
  final List<String> machines;
  final int duration;
  final String dataFrequency;
  final List<AlertContact> contacts;
  final List<AlertCriteria> criteria;
  final bool isActive;

  Alert({
    required this.id,
    required this.name,
    required this.machines,
    required this.duration,
    required this.dataFrequency,
    required this.contacts,
    required this.criteria,
    required this.isActive,
  });

  factory Alert.fromJson(Map<String, dynamic> json) {
    return Alert(
      id: (json['idAlert'] ?? json['id'] ?? json['uuid'] ?? '').toString(),
      name: json['name'] as String? ?? 'Sin nombre',
      machines: (json['machines'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),
      duration: json['duration'] as int? ?? 0,
      dataFrequency: (json['data_frequency'] ?? json['dataFrequency'] ?? '')
          .toString(),
      contacts: (json['contacts'] as List? ?? [])
          .map((e) => AlertContact.fromJson(e as Map<String, dynamic>))
          .toList(),
      criteria: (json['criteria'] as List? ?? [])
          .map((e) => AlertCriteria.fromJson(e as Map<String, dynamic>))
          .toList(),
      isActive: json['is_active'] as bool? ?? json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'machines': machines,
      'duration': duration,
      'data_frequency': dataFrequency,
      'contacts': contacts.map((e) => e.toJson()).toList(),
      'criteria': criteria.map((e) => e.toJson()).toList(),
      'is_active': isActive,
    };
  }
}

class AlertContact {
  final String name;
  final String phone;

  AlertContact({required this.name, required this.phone});

  factory AlertContact.fromJson(Map<String, dynamic> json) {
    return AlertContact(
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'phone': phone};
  }
}

class AlertCriteria {
  final String channel;
  final String condition;
  final double threshold;
  final String? logicalOperator;
  final int? order;

  AlertCriteria({
    required this.channel,
    required this.condition,
    required this.threshold,
    this.logicalOperator,
    this.order,
  });

  factory AlertCriteria.fromJson(Map<String, dynamic> json) {
    return AlertCriteria(
      channel: json['channel'] as String? ?? '',
      condition: json['condition'] as String? ?? '',
      threshold: (json['threshold'] as num? ?? 0.0).toDouble(),
      logicalOperator: json['logical_operator'] as String?,
      order: json['order'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'channel': channel,
      'condition': condition,
      'threshold': threshold,
    };
    if (logicalOperator != null) {
      map['logical_operator'] = logicalOperator;
    }
    if (order != null) {
      map['order'] = order;
    }
    return map;
  }
}
