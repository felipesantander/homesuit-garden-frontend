class AlertHistory {
  final String id;
  final String alertName;
  final String machineSerial;
  final DateTime triggeredAt;
  final List<dynamic> details;
  final List<dynamic> contactsNotified;

  AlertHistory({
    required this.id,
    required this.alertName,
    required this.machineSerial,
    required this.triggeredAt,
    required this.details,
    required this.contactsNotified,
  });

  factory AlertHistory.fromJson(Map<String, dynamic> json) {
    return AlertHistory(
      id: (json['id'] ?? '').toString(),
      alertName: json['alert_name'] as String? ?? '',
      machineSerial: json['machine_serial'] as String? ?? '',
      triggeredAt:
          DateTime.tryParse(json['triggered_at']?.toString() ?? '') ??
          DateTime.now(),
      details: json['details'] as List? ?? [],
      contactsNotified: json['contacts_notified'] as List? ?? [],
    );
  }
}
