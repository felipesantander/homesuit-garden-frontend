import 'package:garden_homesuit/models/machine.model.dart';
import 'package:garden_homesuit/providers/data_latest.provider.dart';
import 'package:garden_homesuit/providers/machines.provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final historicalDataProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((
      ref,
      machineId,
    ) async {
      final service = ref.read(dataServiceProvider);

      // Resolve the machine's dashboard frequency
      final machines = ref.watch(machinesProvider).value ?? [];
      final machine = machines.cast<Machine?>().firstWhere(
        (m) => m?.id == machineId,
        orElse: () => null,
      );

      final frequency = machine?.dashboardFrequency ?? '1_minutes';

      return service.query(machineId: machineId, f: frequency, limit: 50);
    });
