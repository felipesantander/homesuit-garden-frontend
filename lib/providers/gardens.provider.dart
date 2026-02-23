import 'package:garden_homesuit/models/garden.model.dart';
import 'package:garden_homesuit/providers/auth.provider.dart';
import 'package:garden_homesuit/services/garden.service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final gardenServiceProvider = Provider<GardenService>((ref) {
  final authState = ref.watch(authStateProvider);
  return GardenService(
    token: authState?.access ?? '',
    onUnauthorized: () => ref.read(authStateProvider.notifier).clearAuthState(),
  );
});

final gardensProvider = AsyncNotifierProvider<GardensNotifier, List<Garden>>(
  () {
    return GardensNotifier();
  },
);

class GardensNotifier extends AsyncNotifier<List<Garden>> {
  @override
  Future<List<Garden>> build() async {
    return _fetch();
  }

  Future<List<Garden>> _fetch() async {
    final service = ref.read(gardenServiceProvider);
    return service.fetchAll();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetch());
  }

  Future<void> createGarden(String name, String businessId) async {
    final service = ref.read(gardenServiceProvider);
    await service.create({'name': name, 'business': businessId});
    await refresh();
  }

  Future<void> updateGarden(String id, String name) async {
    final service = ref.read(gardenServiceProvider);
    await service.update(id, {'name': name});
    await refresh();
  }

  Future<void> deleteGarden(String id) async {
    final service = ref.read(gardenServiceProvider);
    await service.delete(id);
    await refresh();
  }
}
