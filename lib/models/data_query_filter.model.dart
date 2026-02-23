class DataQueryFilter {
  final String machineId;
  final List<String> channels;
  final String? start;
  final String? end;
  final String frequency;

  const DataQueryFilter({
    required this.machineId,
    this.channels = const [],
    this.start,
    this.end,
    this.frequency = '1_hours',
  });

  DataQueryFilter copyWith({
    String? machineId,
    List<String>? channels,
    String? start,
    String? end,
    String? frequency,
  }) {
    return DataQueryFilter(
      machineId: machineId ?? this.machineId,
      channels: channels ?? this.channels,
      start: start ?? this.start,
      end: end ?? this.end,
      frequency: frequency ?? this.frequency,
    );
  }
}
