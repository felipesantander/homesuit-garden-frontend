import 'package:garden_homesuit/models/machine_candidate.model.dart';
import 'package:garden_homesuit/providers/auth.provider.dart';
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
