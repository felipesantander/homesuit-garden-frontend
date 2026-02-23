import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hooks_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:garden_homesuit/config/app_colors.dart';
import 'package:garden_homesuit/models/data_query_filter.model.dart';
import 'package:garden_homesuit/models/channel.model.dart';
import 'package:garden_homesuit/providers/machines.provider.dart';
import 'package:garden_homesuit/providers/channels.provider.dart';
import 'package:garden_homesuit/providers/data_query.provider.dart';

import 'package:garden_homesuit/views/dashboard/machine_details/components/machine_details_filters.dart';
import 'package:garden_homesuit/views/dashboard/machine_details/components/machine_details_table.dart';
import 'package:garden_homesuit/components/dashboard/widgets/machine_history_chart.dart';
import 'package:garden_homesuit/components/dashboard/widgets/machine_status_badge.dart';
import 'package:garden_homesuit/components/dashboard_card/dashboard_card.component.dart';

// Local state provider for the filters
final detailsFilterProvider = StateProvider.family<DataQueryFilter, String>((
  ref,
  machineId,
) {
  final allMachines = ref.read(machinesProvider).value ?? [];
  final machine = allMachines.where((m) => m.id == machineId).firstOrNull;
  return DataQueryFilter(
    machineId: machineId,
    frequency: machine?.dashboardFrequency ?? '1_hours',
  );
});

// We define a provider that grabs the local state filter and passes it to the generic dataQueryProvider
final currentDetailsDataProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, String>((ref, machineId) {
      final currentFilters = ref.watch(detailsFilterProvider(machineId));
      return ref.watch(dataQueryProvider(currentFilters).future);
    });

class MachineDetailsView extends ConsumerWidget {
  final String machineId;

  const MachineDetailsView({super.key, required this.machineId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allMachines = ref.watch(machinesProvider).value ?? [];
    final allChannels = ref.watch(channelsProvider).value ?? [];

    final machine = allMachines.where((m) => m.id == machineId).firstOrNull;

    if (machine == null) {
      return const Scaffold(
        body: Center(child: Text('Máquina no encontrada o cargando...')),
      );
    }

    // Filter available channels by those mapped to this machine
    final List<Channel> machineChannels = [];
    if (machine.channelMappings != null &&
        machine.channelMappings!.isNotEmpty) {
      final relevantChIds = machine.channelMappings!.values.toList();
      machineChannels.addAll(
        allChannels.where((c) => relevantChIds.contains(c.idChannel)),
      );
    } else {
      machineChannels.addAll(allChannels);
    }

    final currentFilters = ref.watch(detailsFilterProvider(machineId));
    final historyDataAsync = ref.watch(currentDetailsDataProvider(machineId));
    // Determine online status based on historical data context
    bool isOnline = false;
    String? latestCaptureStr;

    if (historyDataAsync.hasValue && historyDataAsync.value != null) {
      final history = historyDataAsync.value!;
      if (history.isNotEmpty) {
        // Find the maximum timestamp in the loaded history payload
        DateTime? newest;
        for (final entry in history) {
          final tstr = entry['timestamp'] as String?;
          if (tstr != null) {
            final dt = DateTime.tryParse(tstr);
            if (dt != null) {
              if (newest == null || dt.isAfter(newest)) {
                newest = dt;
                latestCaptureStr = tstr;
              }
            }
          }
        }

        if (newest != null) {
          final diff = DateTime.now().toUtc().difference(newest);
          isOnline = diff.inMinutes < 30;
        }
      }
    }

    return Container(
      decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Detalles de Sensor'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: BackButton(onPressed: () => context.pop()),
          centerTitle: false,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with machine details
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          machine.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'SN: ${machine.serial.toUpperCase()}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  MachineStatusBadge(
                    isOnline: isOnline,
                    relativeTime: latestCaptureStr ?? 'Nunca',
                    fullTimestamp: latestCaptureStr,
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Filters
              MachineDetailsFilters(
                filter: currentFilters,
                availableChannels: machineChannels,
                supportedFrequencies: machine.supportedFrequencies,
                onFilterChanged: (newFilter) {
                  ref.read(detailsFilterProvider(machineId).notifier).state =
                      newFilter;
                },
              ),
              const SizedBox(height: 32),

              // Chart
              DashboardCard(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Visión Histórica',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 300,
                      child: MachineHistoryChart(
                        historyData: historyDataAsync,
                        isOnline: isOnline,
                        lastSeenRelative: latestCaptureStr ?? '',
                        relativeTime: currentFilters.frequency,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Data Table Tab view
              const Text(
                'Datos Registrados',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              historyDataAsync.when(
                data: (history) {
                  final selectedIds = currentFilters.channels.isNotEmpty
                      ? currentFilters.channels
                      : machineChannels.map((c) => c.idChannel).toList();

                  final tableChannels = machineChannels
                      .where((c) => selectedIds.contains(c.idChannel))
                      .toList();

                  return MachineDetailsTable(
                    historyData: history,
                    selectedChannels: tableChannels,
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Text(
                  'Error cargando historial: $err',
                  style: const TextStyle(color: AppColors.negative),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
