import 'package:garden_homesuit/models/business.model.dart';
import 'package:garden_homesuit/providers/auth.provider.dart';
import 'package:garden_homesuit/services/business.service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final businessServiceProvider = Provider<BusinessService>((ref) {
  final authState = ref.watch(authStateProvider);
  return BusinessService(
    token: authState?.access ?? '',
    onUnauthorized: () => ref.read(authStateProvider.notifier).clearAuthState(),
  );
});

final businessesProvider =
    AsyncNotifierProvider<BusinessesNotifier, List<Business>>(() {
      return BusinessesNotifier();
    });

class BusinessesNotifier extends AsyncNotifier<List<Business>> {
  @override
  Future<List<Business>> build() async {
    return _fetch();
  }

  Future<List<Business>> _fetch() async {
    final service = ref.read(businessServiceProvider);
    return service.fetchAll();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetch());
  }

  Future<void> createBusiness(String name) async {
    final service = ref.read(businessServiceProvider);
    await service.create(name: name);
    await refresh();
  }

  Future<void> updateBusiness(String id, Map<String, dynamic> data) async {
    final service = ref.read(businessServiceProvider);
    await service.update(id, data);
    await refresh();
  }

  Future<void> deleteBusiness(String id) async {
    final service = ref.read(businessServiceProvider);
    await service.delete(id);
    await refresh();
  }
}
