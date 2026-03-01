import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/alert.model.dart';
import '../models/alert_history.model.dart';
import '../services/alert.service.dart';
import 'auth.provider.dart';

final alertServiceProvider = Provider<AlertService>((ref) {
  final authState = ref.watch(authStateProvider);
  return AlertService(
    token: authState?.access ?? '',
    onUnauthorized: () => ref.read(authStateProvider.notifier).clearAuthState(),
  );
});

final alertsProvider = AsyncNotifierProvider<AlertsNotifier, List<Alert>>(
  () => AlertsNotifier(),
);

class AlertsNotifier extends AsyncNotifier<List<Alert>> {
  @override
  Future<List<Alert>> build() async {
    return _fetch();
  }

  Future<List<Alert>> _fetch() async {
    final service = ref.read(alertServiceProvider);
    return service.getAlerts();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetch());
  }

  Future<void> createAlert(Alert alert) async {
    final service = ref.read(alertServiceProvider);
    await service.createAlert(alert);
    await refresh();
  }

  Future<void> updateAlert(String id, Map<String, dynamic> data) async {
    final service = ref.read(alertServiceProvider);
    await service.updateAlert(id, data);
    await refresh();
  }

  Future<void> deleteAlert(String id) async {
    final service = ref.read(alertServiceProvider);
    await service.deleteAlert(id);
    await refresh();
  }

  Future<void> toggleAlert(String id, bool isActive) async {
    await updateAlert(id, {'is_active': isActive});
  }
}

final alertHistoryProvider = FutureProvider<List<AlertHistory>>((ref) async {
  final service = ref.watch(alertServiceProvider);
  return await service.getAlertHistory();
});
