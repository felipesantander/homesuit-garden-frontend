import 'package:garden_homesuit/providers/auth.provider.dart';
import 'package:garden_homesuit/services/configuration_channel.service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final configurationChannelServiceProvider =
    Provider<ConfigurationChannelService>((ref) {
      final authState = ref.watch(authStateProvider);
      return ConfigurationChannelService(
        token: authState?.access ?? '',
        onUnauthorized: () =>
            ref.read(authStateProvider.notifier).clearAuthState(),
      );
    });

final configurationChannelsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
      final service = ref.read(configurationChannelServiceProvider);
      return service.fetchAll();
    });
