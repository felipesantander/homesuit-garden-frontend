import 'package:flutter/material.dart';
import 'package:garden_homesuit/components/channel/channel_card.component.dart';
import 'package:garden_homesuit/components/channel/channel_form.component.dart';
import 'package:garden_homesuit/config/app_colors.dart';
import 'package:garden_homesuit/models/business.model.dart';
import 'package:garden_homesuit/models/channel.model.dart';
import 'package:garden_homesuit/providers/channels.provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:garden_homesuit/providers/businesses.provider.dart';
import 'package:garden_homesuit/providers/view_filters.provider.dart';

class ChannelsMobileView extends ConsumerWidget {
  const ChannelsMobileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final channelsAsync = ref.watch(channelsProvider);
    final selectedBusinessIds = ref.watch(channelBusinessFilterProvider);
    final businessesAsync = ref.watch(businessesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Canales',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: () => ref.read(channelsProvider.notifier).refresh(),
            tooltip: 'Refrescar',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: channelsAsync.when(
          data: (channels) {
            return businessesAsync.when(
              data: (businesses) => _GroupedChannelsList(
                channels: channels,
                businesses: businesses,
                selectedBusinessIds: selectedBusinessIds,
              ),
              loading: () => const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
              error: (err, _) => _ErrorState(error: err),
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          error: (err, stack) => _ErrorState(error: err),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: FloatingActionButton(
          onPressed: () => _showFormBottomSheet(context),
          backgroundColor: AppColors.primary,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
        ),
      ),
    );
  }

  void _showFormBottomSheet(BuildContext context, {Channel? channel}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: ChannelForm(
                channel: channel,
                onSaved: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GroupedChannelsList extends StatelessWidget {
  final List<Channel> channels;
  final List<dynamic> businesses;
  final Set<String> selectedBusinessIds;

  const _GroupedChannelsList({
    required this.channels,
    required this.businesses,
    required this.selectedBusinessIds,
  });

  @override
  Widget build(BuildContext context) {
    final filteredChannels = channels.where((channel) {
      if (selectedBusinessIds.isEmpty) return true;
      return selectedBusinessIds.contains(channel.business);
    }).toList();

    if (filteredChannels.isEmpty) {
      return const _EmptyState();
    }

    final Map<String, List<Channel>> grouped = {};
    for (final channel in filteredChannels) {
      final bizId = channel.business ?? 'unassigned';
      grouped.putIfAbsent(bizId, () => []).add(channel);
    }

    final sortedBizIds = grouped.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 160),
      itemCount: sortedBizIds.length,
      itemBuilder: (context, bizIndex) {
        final bizId = sortedBizIds[bizIndex];
        final bizChannels = grouped[bizId]!;

        final business = bizId == 'unassigned'
            ? null
            : businesses.cast<Business?>().firstWhere(
                (b) => b?.idBusiness == bizId,
                orElse: () => null,
              );

        final label = bizId == 'unassigned'
            ? 'Sin Negocio'
            : (business?.name ?? 'Negocio Desconocido');

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            ...bizChannels.map(
              (channel) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SizedBox(
                  height: 220,
                  child: ChannelCard(
                    channel: channel,
                    onEdit: () => const ChannelsMobileView()
                        ._showFormBottomSheet(context, channel: channel),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.sensors_off_rounded,
                size: 80,
                color: AppColors.primary.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'No hay canales',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Configura tus canales de comunicación para recibir datos de tus sensores.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final Object error;

  const _ErrorState({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Error: $error',
        style: const TextStyle(color: AppColors.negative),
      ),
    );
  }
}
