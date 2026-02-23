import 'package:garden_homesuit/models/channel.model.dart';
import 'package:garden_homesuit/providers/auth.provider.dart';
import 'package:garden_homesuit/services/channel.service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final channelServiceProvider = Provider<ChannelService>((ref) {
  final authState = ref.watch(authStateProvider);
  return ChannelService(
    token: authState?.access ?? '',
    onUnauthorized: () => ref.read(authStateProvider.notifier).clearAuthState(),
  );
});

final channelsProvider = AsyncNotifierProvider<ChannelsNotifier, List<Channel>>(
  () {
    return ChannelsNotifier();
  },
);

class ChannelsNotifier extends AsyncNotifier<List<Channel>> {
  @override
  Future<List<Channel>> build() async {
    return _fetch();
  }

  Future<List<Channel>> _fetch() async {
    final service = ref.read(channelServiceProvider);
    return service.fetchAll();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetch());
  }

  Future<void> createChannel(
    String name, {
    required String unit,
    String? businessId,
  }) async {
    final service = ref.read(channelServiceProvider);
    await service.create(name: name, unit: unit, business: businessId);
    await refresh();
  }

  Future<void> updateChannel(String id, Map<String, dynamic> data) async {
    final service = ref.read(channelServiceProvider);
    await service.update(id, data);
    await refresh();
  }

  Future<void> deleteChannel(String id) async {
    final service = ref.read(channelServiceProvider);
    await service.delete(id);
    await refresh();
  }
}
