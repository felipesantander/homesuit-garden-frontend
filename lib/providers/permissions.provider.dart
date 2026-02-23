import 'package:garden_homesuit/models/permission.model.dart';
import 'package:garden_homesuit/providers/auth.provider.dart';
import 'package:garden_homesuit/services/permissions.service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final permissionsServiceProvider = Provider<PermissionsService>((ref) {
  final authState = ref.watch(authStateProvider);
  return PermissionsService(
    token: authState?.access ?? '',
    onUnauthorized: () => ref.read(authStateProvider.notifier).clearAuthState(),
  );
});

final permissionsProvider =
    AsyncNotifierProvider<PermissionsNotifier, List<Permission>>(() {
      return PermissionsNotifier();
    });

class PermissionsNotifier extends AsyncNotifier<List<Permission>> {
  @override
  Future<List<Permission>> build() async {
    return _fetch();
  }

  Future<List<Permission>> _fetch() async {
    final service = ref.read(permissionsServiceProvider);
    return service.fetchAll();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetch());
  }

  Future<void> createPermission(Map<String, dynamic> data) async {
    final service = ref.read(permissionsServiceProvider);
    await service.create(data);
    await refresh();
  }

  Future<void> updatePermission(String id, Map<String, dynamic> data) async {
    final service = ref.read(permissionsServiceProvider);
    await service.update(id, data);
    await refresh();
  }

  Future<void> deletePermission(String id) async {
    final service = ref.read(permissionsServiceProvider);
    await service.delete(id);
    await refresh();
  }
}
