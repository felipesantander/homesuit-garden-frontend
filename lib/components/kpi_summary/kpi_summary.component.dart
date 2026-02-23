import 'package:flutter/material.dart';
import 'package:garden_homesuit/config/app_colors.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'kpi_stats.provider.dart';
import 'widgets/kpi_card.dart';

class KpiSummaryHeader extends ConsumerWidget {
  const KpiSummaryHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(dashboardStatsProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Wrap(
        alignment: WrapAlignment.start,
        spacing: 16,
        runSpacing: 16,
        children: [
          KpiCard(
            label: 'Dispositivos',
            value: '${stats['total']}',
            icon: Icons.sensors_rounded,
            color: AppColors.primary,
          ),
          KpiCard(
            label: 'Online',
            value: '${stats['online']}',
            icon: Icons.wifi_tethering_rounded,
            color: AppColors.water,
            isAnimate: (stats['online'] as int) > 0,
          ),
          KpiCard(
            label: 'Offline',
            value: '${stats['offline']}',
            icon: Icons.wifi_tethering_off_rounded,
            color: AppColors.negative,
          ),
        ],
      ),
    );
  }
}
