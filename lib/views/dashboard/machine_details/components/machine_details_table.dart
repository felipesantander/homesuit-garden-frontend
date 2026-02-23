import 'package:flutter/material.dart';
import 'package:garden_homesuit/config/app_colors.dart';
import 'package:intl/intl.dart';

import 'package:garden_homesuit/models/channel.model.dart';

class MachineDetailsTable extends StatelessWidget {
  final List<Map<String, dynamic>> historyData;
  final List<Channel> selectedChannels;

  const MachineDetailsTable({
    super.key,
    required this.historyData,
    required this.selectedChannels,
  });

  @override
  Widget build(BuildContext context) {
    if (historyData.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text(
            'No hay datos históricos para los filtros seleccionados.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    if (selectedChannels.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text(
            'Selecciona al menos un canal para visualizar la tabla.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
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

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.6),
          width: 1.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 600),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(AppColors.surface),
              columns: [
                const DataColumn(
                  label: Text(
                    'Fecha / Hora',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                ...selectedChannels.map(
                  (c) => DataColumn(
                    label: Text(
                      c.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
              rows: sortedTimes.map((timeStr) {
                final rowData = groupedByTime[timeStr]!;
                final dt =
                    DateTime.tryParse(timeStr)?.toLocal() ?? DateTime.now();

                return DataRow(
                  cells: [
                    DataCell(
                      RichText(
                        text: TextSpan(
                          text: DateFormat('dd/MM/yyyy').format(dt),
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                          children: [
                            const TextSpan(text: '   '),
                            TextSpan(
                              text: DateFormat('HH:mm:ss').format(dt),
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    ...selectedChannels.map((c) {
                      final chId = c.idChannel;
                      // Try to find the value by ID first, then fallback to name or formatted name
                      // The API occasionally returns 'type' as the name instead of the ID.
                      final val =
                          rowData[chId] ??
                          rowData[c.name] ??
                          rowData[c.name.toLowerCase()];

                      final displayVal = val != null ? val.toString() : '--';
                      return DataCell(
                        Text(
                          displayVal,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      );
                    }),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
