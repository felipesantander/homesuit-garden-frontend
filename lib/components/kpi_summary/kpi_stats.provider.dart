import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:garden_homesuit/providers/data_latest.provider.dart';
import 'package:garden_homesuit/providers/machines.provider.dart';

final dashboardStatsProvider = Provider((ref) {
  final machines = ref.watch(machinesProvider).asData?.value ?? [];
  int onlineCount = 0;
  double totalPower = 0;

  for (final machine in machines) {
    final latestData = ref
        .watch(latestDataProvider(machine.serial))
        .asData
        ?.value;
    if (latestData != null && latestData.isNotEmpty) {
      final firstRecord = latestData.values.first as Map<String, dynamic>;
      final timestamp = firstRecord['t'] as String?;
      if (timestamp != null) {
        try {
          final lastCapture = DateTime.parse(timestamp);
          final isOnline =
              DateTime.now().toUtc().difference(lastCapture).inMinutes < 30;
          if (isOnline) {
            onlineCount++;

            final powerKey = machine.channelMappings?.entries
                .firstWhere(
                  (entry) => entry.value.toLowerCase().contains('power'),
                  orElse: () => const MapEntry('', ''),
                )
                .key;

            final powerVal =
                latestData[powerKey ?? 'power']?['v'] ??
                latestData['Power']?['v'];

            if (powerVal != null) {
              totalPower += (powerVal as num).toDouble();
            }
          }
        } catch (_) {}
      }
    }
  }

  return {
    'total': machines.length,
    'online': onlineCount,
    'offline': machines.length - onlineCount,
    'power': totalPower,
  };
});
