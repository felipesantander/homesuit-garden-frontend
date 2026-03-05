import 'package:flutter/material.dart';
import 'package:garden_homesuit/components/channel/channel_card.component.dart';
import 'package:garden_homesuit/components/channel/channel_form.component.dart';
import 'package:garden_homesuit/config/app_colors.dart';
import 'package:garden_homesuit/models/business.model.dart';
import 'package:garden_homesuit/models/channel.model.dart';
import 'package:garden_homesuit/providers/channels.provider.dart';
import 'package:garden_homesuit/providers/auth.provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:garden_homesuit/components/common/business_filter.component.dart';
import 'package:garden_homesuit/providers/businesses.provider.dart';
import 'package:garden_homesuit/providers/view_filters.provider.dart';

class ChannelsView extends ConsumerWidget {
  const ChannelsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final channelsAsync = ref.watch(channelsProvider);
    final selectedBusinessIds = ref.watch(channelBusinessFilterProvider);
    final businessesAsync = ref.watch(businessesProvider);
    final authData = ref.watch(authStateProvider);
    final authorizedComponents = authData?.components ?? [];

    if (!authorizedComponents.contains('channels_see')) {
      return const Center(child: Text('No tienes permiso para ver canales'));
    }

    final canAdd = authorizedComponents.contains('channels_add');

    return Container(
      decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(
            onAdd: canAdd ? () => _showFormDialog(context) : null,
            onRefresh: () => ref.read(channelsProvider.notifier).refresh(),
            selectedBusinessIds: selectedBusinessIds,
            onFilterApplied: (ids) =>
                ref.read(channelBusinessFilterProvider.notifier).state = ids,
          ),
          Expanded(
            child: channelsAsync.when(
              data: (channels) {
                return businessesAsync.when(
                  data: (businesses) => _GroupedChannelsList(
                    channels: channels,
                    businesses: businesses,
                    selectedBusinessIds: selectedBusinessIds,
                  ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, _) => _ErrorState(error: err),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => _ErrorState(error: err),
            ),
          ),
        ],
      ),
    );
  }

  void _showFormDialog(BuildContext context, {Channel? channel}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: const EdgeInsets.all(24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: SizedBox(
          width: 450,
          child: ChannelForm(
            channel: channel,
            onSaved: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    channel == null
                        ? 'Canal creado exitosamente'
                        : 'Canal actualizado exitosamente',
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback? onAdd;
  final VoidCallback onRefresh;
  final Set<String> selectedBusinessIds;
  final Function(Set<String>) onFilterApplied;

  const _Header({
    required this.onAdd,
    required this.onRefresh,
    required this.selectedBusinessIds,
    required this.onFilterApplied,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: const Icon(
                  Icons.sensors_rounded,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Gestión de Canales',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Row(
                    children: [
                      const Text(
                        'Canales de entrada de datos',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 16),
                      BusinessFilter(
                        selectedIds: selectedBusinessIds,
                        onApplied: onFilterApplied,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh_rounded),
                color: AppColors.primary,
                tooltip: 'Refrescar',
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  padding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(width: 16),
              if (onAdd != null)
                ElevatedButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add_task_rounded, size: 20),
                  label: const Text(
                    'NUEVO CANAL',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  style:
                      ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 20,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ).copyWith(
                        overlayColor: WidgetStateProperty.all(
                          Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                ),
            ],
          ),
        ],
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
    // 1. Filter
    final filteredChannels = channels.where((channel) {
      if (selectedBusinessIds.isEmpty) return true;
      return selectedBusinessIds.contains(channel.business);
    }).toList();

    if (filteredChannels.isEmpty) {
      return const _EmptyState();
    }

    // 2. Group
    final Map<String, List<Channel>> grouped = {};
    for (final channel in filteredChannels) {
      final bizId = channel.business ?? 'unassigned';
      grouped.putIfAbsent(bizId, () => []).add(channel);
    }

    final sortedBizIds = grouped.keys.toList();

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(24),
          sliver: SliverMainAxisGroup(
            slivers: [
              for (final bizId in sortedBizIds) ...[
                SliverToBoxAdapter(
                  child: _BusinessHeader(
                    bizId: bizId,
                    businesses: businesses,
                    count: grouped[bizId]?.length ?? 0,
                  ),
                ),
                SliverGrid(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 400,
                    mainAxisExtent: 220,
                    crossAxisSpacing: 24,
                    mainAxisSpacing: 24,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final channel = grouped[bizId]![index];
                    return ChannelCard(
                      channel: channel,
                      onEdit: () => const ChannelsView()._showFormDialog(
                        context,
                        channel: channel,
                      ),
                    );
                  }, childCount: grouped[bizId]?.length ?? 0),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _BusinessHeader extends StatelessWidget {
  final String bizId;
  final List<dynamic> businesses;
  final int count;

  const _BusinessHeader({
    required this.bizId,
    required this.businesses,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final business = bizId == 'unassigned'
        ? null
        : businesses.cast<Business?>().firstWhere(
            (b) => b?.idBusiness == bizId,
            orElse: () => null,
          );

    final label = bizId == 'unassigned'
        ? 'Sin Negocio'
        : (business?.name ?? 'Negocio Desconocido');

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.business_center_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(child: Divider(height: 1, color: AppColors.border)),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sensors_off_rounded, size: 64, color: AppColors.textMuted),
          SizedBox(height: 16),
          Text(
            'No se encontraron canales con los filtros aplicados',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
        ],
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.negative),
          const SizedBox(height: 16),
          Text(
            'Error al cargar canales: $error',
            style: const TextStyle(color: AppColors.negative),
          ),
        ],
      ),
    );
  }
}
