import 'package:flutter/material.dart';
import 'package:garden_homesuit/components/garden/garden_card.component.dart';
import 'package:garden_homesuit/components/garden/garden_form.component.dart';
import 'package:garden_homesuit/config/app_colors.dart';
import 'package:garden_homesuit/models/business.model.dart';
import 'package:garden_homesuit/models/garden.model.dart';
import 'package:garden_homesuit/providers/gardens.provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:garden_homesuit/components/common/business_filter.component.dart';
import 'package:garden_homesuit/providers/businesses.provider.dart';
import 'package:garden_homesuit/providers/view_filters.provider.dart';

class GardensView extends ConsumerWidget {
  const GardensView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gardensAsync = ref.watch(gardensProvider);
    final selectedBusinessIds = ref.watch(gardenBusinessFilterProvider);
    final businessesAsync = ref.watch(businessesProvider);

    return Container(
      decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(
            onAdd: () => _showFormDialog(context),
            onRefresh: () => ref.read(gardensProvider.notifier).refresh(),
            selectedBusinessIds: selectedBusinessIds,
            onFilterApplied: (ids) =>
                ref.read(gardenBusinessFilterProvider.notifier).state = ids,
          ),
          Expanded(
            child: gardensAsync.when(
              data: (gardens) {
                return businessesAsync.when(
                  data: (businesses) => _GroupedGardensList(
                    gardens: gardens,
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

  void _showFormDialog(BuildContext context, {Garden? garden}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: const EdgeInsets.all(24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: SizedBox(
          width: 450,
          child: GardenForm(
            garden: garden,
            onSaved: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    garden == null
                        ? 'Jardín creado exitosamente'
                        : 'Jardín actualizado exitosamente',
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
  final VoidCallback onAdd;
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Gestión de Jardines',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Text(
                      'Administra tus espacios de cultivo',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
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
          ),
          Row(
            children: [
              IconButton(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh, color: AppColors.primary),
                tooltip: 'Refrescar',
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.library_add_rounded),
                label: const Text('NUEVO JARDÍN'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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

class _GroupedGardensList extends StatelessWidget {
  final List<Garden> gardens;
  final List<dynamic> businesses;
  final Set<String> selectedBusinessIds;

  const _GroupedGardensList({
    required this.gardens,
    required this.businesses,
    required this.selectedBusinessIds,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Filter
    final filteredGardens = gardens.where((garden) {
      if (selectedBusinessIds.isEmpty) return true;
      return selectedBusinessIds.contains(garden.business);
    }).toList();

    if (filteredGardens.isEmpty) {
      return const _EmptyState();
    }

    // 2. Group
    final Map<String, List<Garden>> grouped = {};
    for (final garden in filteredGardens) {
      final bizId = garden.business;
      grouped.putIfAbsent(bizId, () => []).add(garden);
    }

    // Sort businesses to match grouping if needed
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
                    final garden = grouped[bizId]![index];
                    return GardenCard(
                      garden: garden,
                      onEdit: () => const GardensView()._showFormDialog(
                        context,
                        garden: garden,
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
    final business = businesses.cast<Business?>().firstWhere(
      (b) => b?.idBusiness == bizId,
      orElse: () => null,
    );

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
                  business?.name ?? 'Negocio Desconocido',
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
          Icon(Icons.eco_outlined, size: 64, color: AppColors.textMuted),
          SizedBox(height: 16),
          Text(
            'No se encontraron jardines con los filtros aplicados',
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
            'Error al cargar jardines: $error',
            style: const TextStyle(color: AppColors.negative),
          ),
        ],
      ),
    );
  }
}
