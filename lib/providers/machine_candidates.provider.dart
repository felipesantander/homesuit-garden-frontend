import 'package:garden_homesuit/models/machine_candidate.model.dart';
import 'package:garden_homesuit/providers/auth.provider.dart';
import 'package:garden_homesuit/providers/machines.provider.dart';
import 'package:garden_homesuit/providers/data_latest.provider.dart';
import 'package:garden_homesuit/services/machine_candidate.service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final machineCandidateServiceProvider = Provider<MachineCandidateService>((
  ref,
) {
  final authState = ref.watch(authStateProvider);
  return MachineCandidateService(
    token: authState?.access ?? '',
    onUnauthorized: () => ref.read(authStateProvider.notifier).clearAuthState(),
  );
});

final machineCandidatesProvider =
    AsyncNotifierProvider<MachineCandidatesNotifier, List<MachineCandidate>>(
      () => MachineCandidatesNotifier(),
    );

class MachineCandidatesNotifier extends AsyncNotifier<List<MachineCandidate>> {
  @override
  Future<List<MachineCandidate>> build() async {
    return _fetch();
  }

  Future<List<MachineCandidate>> _fetch() async {
    final service = ref.read(machineCandidateServiceProvider);
    return service.fetchAll();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetch());
  }

  Future<void> deleteCandidate(String id) async {
    final service = ref.read(machineCandidateServiceProvider);
    await service.delete(id);
    await refresh();
  }
}

final machineCandidateBySerialProvider =
    Provider.family<MachineCandidate?, String>((ref, serial) {
      final candidates = ref.watch(machineCandidatesProvider).value ?? [];
      try {
        return candidates.firstWhere((c) => c.serial == serial);
      } catch (_) {
        return null;
      }
    });

final machineConfigurationTargetProvider =
    Provider.family<MachineCandidate?, String>((ref, serial) {
      // 1. Check if it's a known candidate (unregistered)
      final candidates = ref.watch(machineCandidatesProvider).value ?? [];
      final candidate = candidates.where((c) => c.serial == serial).firstOrNull;

      // 2. Check if it's an already registered machine
      final machines = ref.watch(machinesProvider).value ?? [];
      final machine = machines.where((m) => m.serial == serial).firstOrNull;

      // 3. Check for discovery via telemetry (live data)
      final latestDataAsync = ref.watch(latestDataProvider(serial));
      final latestTypes = latestDataAsync.value?.keys ?? [];

      if (machine == null && candidate == null && latestTypes.isEmpty) {
        return null;
      }

      // Merge all known types
      final Set<String> allTypes = {};
      if (candidate != null) allTypes.addAll(candidate.types);
      if (machine?.channelMappings != null) {
        allTypes.addAll(machine!.channelMappings!.keys);
      }
      allTypes.addAll(latestTypes);

      // Sanitize técnicos
      allTypes.removeWhere(
        (t) => t == 'serial' || t == 'timestamp' || t == 'id' || t == 'msg',
      );

      return MachineCandidate(
        id: machine?.id ?? candidate?.id ?? '',
        serial: serial,
        types: allTypes.toList(),
        discoveredAt: candidate?.discoveredAt ?? DateTime.now(),
      );
    });
