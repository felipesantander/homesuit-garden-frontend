import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:garden_homesuit/config/app_colors.dart';
import 'package:garden_homesuit/providers/auth.provider.dart';
import 'package:go_router/go_router.dart';

import 'package:garden_homesuit/components/dashboard/machine_dashboard_card.component.dart';
import 'package:garden_homesuit/components/kpi_summary/kpi_summary.component.dart';
import 'package:garden_homesuit/providers/machines.provider.dart';
import 'package:garden_homesuit/providers/gardens.provider.dart';
import 'package:garden_homesuit/models/machine.model.dart';
import 'package:garden_homesuit/components/dashboard/widgets/global_filters.component.dart';
import 'package:garden_homesuit/providers/dashboard_filters.provider.dart';

class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final machinesAsync = ref.watch(machinesProvider);

    return Container(
      decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dashboard',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Panel de Monitoreo IoT',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.refresh,
                          color: AppColors.primary,
                        ),
                        onPressed: () =>
                            ref.read(machinesProvider.notifier).refresh(),
                        tooltip: 'Recargar Datos',
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(
                          Icons.logout,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () async {
                          await ref.read(logoutActionProvider)();
                          if (context.mounted) {
                            context.go('/login');
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const KpiSummaryHeader(),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: GlobalFiltersComponent(),
            ),

            // Main content
            Expanded(
              child: machinesAsync.when(
                data: (machines) => _GroupedMachinesList(machines: machines),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => _ErrorState(error: err),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupedMachinesList extends ConsumerWidget {
  final List<Machine> machines;

  const _GroupedMachinesList({required this.machines});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gardensAsync = ref.watch(gardensProvider);
    final selectedBusinessIds = ref.watch(selectedBusinessIdsProvider);
    final selectedGardenIds = ref.watch(selectedGardenIdsProvider);

    if (machines.isEmpty) {
      return const _EmptyState();
    }

    final gardens = gardensAsync.asData?.value ?? [];

    final filteredMachines = machines.where((machine) {
      // Find the garden for this machine to check its business
      final garden = gardens.firstWhere(
        (g) => g.idGarden == machine.garden || g.name == machine.garden,
        orElse: () => gardens.first,
      );

      final gardenMatches = (gardens.any(
        (g) => g.idGarden == machine.garden || g.name == machine.garden,
      ));
      if (!gardenMatches && gardens.isNotEmpty) {
        // If machine doesn't belong to any known garden, it's "Other"
      }

      // 1. Business Filter
      if (selectedBusinessIds.isNotEmpty) {
        if (!selectedBusinessIds.contains(garden.business)) {
          return false;
        }
      }

      // 2. Garden Filter
      if (selectedGardenIds.isNotEmpty) {
        if (!selectedGardenIds.contains(garden.idGarden)) {
          return false;
        }
      }

      return true;
    }).toList();

    if (filteredMachines.isEmpty) {
      return const _EmptyState(isFiltered: true);
    }

    // Grouping logic
    final Map<String, List<Machine>> grouped = {};
    for (final machine in filteredMachines) {
      String name = 'Otros Dispositivos';
      if (gardens.isNotEmpty) {
        final g = gardens.firstWhere(
          (g) => g.idGarden == machine.garden || g.name == machine.garden,
          orElse: () => gardens.first,
        );
        name = g.name;
      }
      grouped.putIfAbsent(name, () => []).add(machine);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final gardenName = grouped.keys.elementAt(index);
        final gardenMachines = grouped[gardenName]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(
                    Icons.eco_rounded,
                    size: 20,
                    color: AppColors.positive,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    gardenName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '· ${gardenMachines.length} dispositivos',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 320,
                mainAxisExtent: 360, // Back to 360 for upcoming redesign
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
              ),
              itemCount: gardenMachines.length,
              itemBuilder: (context, gIndex) {
                return MachineDashboardCard(
                  machine: gardenMachines[gIndex],
                  onTap: () {},
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isFiltered;
  const _EmptyState({this.isFiltered = false});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isFiltered ? Icons.filter_list_off_rounded : Icons.eco_outlined,
            size: 80,
            color: AppColors.primary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 24),
          Text(
            isFiltered
                ? 'No hay resultados con estos filtros'
                : 'No tienes máquinas registradas',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isFiltered
                ? 'Prueba ajustando los filtros de empresa o jardín.'
                : 'Usa el menú lateral para registrar\ntu primer dispositivo.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
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
            'Error al cargar máquinas: $error',
            style: const TextStyle(color: AppColors.negative),
          ),
        ],
      ),
    );
  }
}
