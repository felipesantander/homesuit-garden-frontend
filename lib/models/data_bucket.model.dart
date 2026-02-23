class SensorReading {
  final double value;
  final String timestamp;
  final String frequency;

  SensorReading({
    required this.value,
    required this.timestamp,
    required this.frequency,
  });

  factory SensorReading.fromJson(Map<String, dynamic> json) {
    return SensorReading(
      value: (json['v'] as num).toDouble(),
      timestamp: json['t'] as String,
      frequency: json['f'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'v': value, 't': timestamp, 'f': frequency};
  }
}

class DataBucket {
  final String id;
  final String baseDate;
  final int count;
  final List<SensorReading> readings;

  DataBucket({
    required this.id,
    required this.baseDate,
    required this.count,
    required this.readings,
  });

  factory DataBucket.fromJson(Map<String, dynamic> json) {
    return DataBucket(
      id: json['id'].toString(),
      baseDate: json['base_date'] as String,
      count: json['count'] as int,
      readings: (json['readings'] as List<dynamic>)
          .map((r) => SensorReading.fromJson(r as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'base_date': baseDate,
      'count': count,
      'readings': readings.map((r) => r.toJson()).toList(),
    };
  }
}
