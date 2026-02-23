import 'package:garden_homesuit/models/role.model.dart';
import 'package:garden_homesuit/providers/auth.provider.dart';
import 'package:garden_homesuit/services/roles.service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final rolesServiceProvider = Provider<RolesService>((ref) {
  final authState = ref.watch(authStateProvider);
  return RolesService(
    token: authState?.access ?? '',
    onUnauthorized: () => ref.read(authStateProvider.notifier).clearAuthState(),
  );
});

final rolesProvider = AsyncNotifierProvider<RolesNotifier, List<Role>>(() {
  return RolesNotifier();
});

class RolesNotifier extends AsyncNotifier<List<Role>> {
  @override
  Future<List<Role>> build() async {
    return _fetch();
  }

  Future<List<Role>> _fetch() async {
    final service = ref.read(rolesServiceProvider);
    return service.fetchAll();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetch());
  }

  Future<void> createRole(Map<String, dynamic> data) async {
    final service = ref.read(rolesServiceProvider);
    await service.create(data);
    await refresh();
  }

  Future<void> updateRole(String id, Map<String, dynamic> data) async {
    final service = ref.read(rolesServiceProvider);
    await service.update(id, data);
    await refresh();
  }

  Future<void> deleteRole(String id) async {
    final service = ref.read(rolesServiceProvider);
    await service.delete(id);
    await refresh();
  }
}
