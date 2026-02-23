import 'package:garden_homesuit/providers/auth.provider.dart';
import 'package:garden_homesuit/services/data.service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final dataServiceProvider = Provider<DataService>((ref) {
  final authState = ref.watch(authStateProvider);
  return DataService(
    token: authState?.access ?? '',
    onUnauthorized: () => ref.read(authStateProvider.notifier).clearAuthState(),
  );
});

final latestDataProvider = FutureProvider.family<Map<String, dynamic>, String>((
  ref,
  serial,
) async {
  final service = ref.read(dataServiceProvider);
  return service.fetchLatestBySerial(serial);
});
