import 'package:flutter/material.dart';
import 'package:garden_homesuit/config/app_colors.dart';
import 'package:intl/intl.dart';

import 'package:garden_homesuit/utils/icon_utils.dart';

import 'package:garden_homesuit/models/channel.model.dart';
import 'package:garden_homesuit/components/dashboard_card/dashboard_card.component.dart';

class MachineDetailsTable extends StatelessWidget {
  final List<Map<String, dynamic>> historyData;
  final List<Channel> selectedChannels;

  const MachineDetailsTable({
    super.key,
    required this.historyData,
    required this.selectedChannels,
  });

  Widget _buildEmptyState(String message) {
    return DashboardCard(
      width: double.infinity,
      borderRadius: 24,
      padding: EdgeInsets.zero,
      child: Container(
        constraints: const BoxConstraints(minHeight: 200),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.table_chart_outlined,
                color: AppColors.textSecondary.withValues(alpha: 0.3),
                size: 48,
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (historyData.isEmpty) {
      return _buildEmptyState(
        'No hay datos históricos para los filtros seleccionados.',
      );
    }

    if (selectedChannels.isEmpty) {
      return _buildEmptyState(
        'Selecciona al menos un canal para visualizar la tabla.',
      );
    }

    // Transform flat [{timestamp, type, value}] data into a timestamp grouped map
    final Map<String, Map<String, dynamic>> groupedByTime = {};
    for (final entry in historyData) {
      final timeStr = entry['timestamp'] as String?;
      if (timeStr == null) continue;

      if (!groupedByTime.containsKey(timeStr)) {
        groupedByTime[timeStr] = {'timestamp': timeStr};
      }
      final type = entry['type'] as String?;
      if (type != null) {
        groupedByTime[timeStr]![type] = entry['value'];
      }
    }

    // Sort by timestamp descending
    final sortedTimes = groupedByTime.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return DashboardCard(
      borderRadius: 24,
      padding: EdgeInsets.zero,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 600),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(
                AppColors.background.withValues(alpha: 0.5),
              ),
              dataRowColor: WidgetStateProperty.resolveWith<Color?>((
                Set<WidgetState> states,
              ) {
                return null; // Let alternating rows handle it if we used Theme,
                // but here we can manually alternate if we want.
              }),
              // Flutter DataTable doesn't have a direct zebra property,
              // we can handle it by mapping with index.
              columns: [
                const DataColumn(
                  label: Text(
                    'Fecha / Hora',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                ...selectedChannels.map(
                  (c) => DataColumn(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          IconUtils.getIconForNameOrType(c.icon, c.name),
                          size: 16,
                          color: IconUtils.getColorForNameOrType(
                            c.icon,
                            c.name,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          c.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              rows: List.generate(sortedTimes.length, (index) {
                final timeStr = sortedTimes[index];
                final rowData = groupedByTime[timeStr]!;
                final dt =
                    DateTime.tryParse(timeStr)?.toLocal() ?? DateTime.now();
                final isEven = index % 2 == 0;

                return DataRow(
                  color: WidgetStateProperty.all(
                    isEven
                        ? Colors.transparent
                        : AppColors.background.withValues(alpha: 0.3),
                  ),
                  cells: [
                    DataCell(
                      RichText(
                        text: TextSpan(
                          text: DateFormat('dd/MM/yyyy').format(dt),
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                          children: [
                            const TextSpan(text: '  '),
                            TextSpan(
                              text: DateFormat('HH:mm').format(dt),
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    ...selectedChannels.map((c) {
                      final chId = c.idChannel;
                      final val =
                          rowData[chId] ??
                          rowData[c.name] ??
                          rowData[c.name.toLowerCase()];

                      final displayVal = val != null ? val.toString() : '--';
                      return DataCell(
                        Text(
                          displayVal,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: val != null
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                        ),
                      );
                    }),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
