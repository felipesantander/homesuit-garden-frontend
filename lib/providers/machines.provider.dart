import 'package:garden_homesuit/models/machine.model.dart';
import 'package:garden_homesuit/providers/auth.provider.dart';
import 'package:garden_homesuit/services/machine.service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final machineServiceProvider = Provider<MachineService>((ref) {
  final authState = ref.watch(authStateProvider);
  return MachineService(
    token: authState?.access ?? '',
    onUnauthorized: () => ref.read(authStateProvider.notifier).clearAuthState(),
  );
});

final machinesProvider = AsyncNotifierProvider<MachinesNotifier, List<Machine>>(
  () {
    return MachinesNotifier();
  },
);

class MachinesNotifier extends AsyncNotifier<List<Machine>> {
  @override
  Future<List<Machine>> build() async {
    return _fetch();
  }

  Future<List<Machine>> _fetch() async {
    final service = ref.read(machineServiceProvider);
    return service.fetchAll();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetch());
  }

  Future<void> createMachine(String serial, String name) async {
    final service = ref.read(machineServiceProvider);
    await service.create(serial: serial, name: name);
    await refresh();
  }

  Future<void> deleteMachine(String id) async {
    final service = ref.read(machineServiceProvider);
    await service.delete(id);
    await refresh();
  }
}
