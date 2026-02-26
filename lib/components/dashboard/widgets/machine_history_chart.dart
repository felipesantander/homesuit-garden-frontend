import 'package:flutter/material.dart';
import 'package:garden_homesuit/config/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class MachineHistoryChart extends StatelessWidget {
  final AsyncValue<List<Map<String, dynamic>>> historyData;
  final bool isOnline;
  final String? lastSeenRelative;
  final String relativeTime;

  const MachineHistoryChart({
    super.key,
    required this.historyData,
    required this.isOnline,
    required this.relativeTime,
    this.lastSeenRelative,
  });

  @override
  Widget build(BuildContext context) {
    return historyData.when(
      data: (data) {
        if (data.isEmpty) {
          return _buildEmptyState();
        }

        // Group data by type/channel for multiple lines
        final Map<String, List<Map<String, dynamic>>> grouped = {};
        for (final entry in data) {
          final type = entry['type'] as String;
          grouped.putIfAbsent(type, () => []).add(entry);
        }

        return SfCartesianChart(
          plotAreaBorderWidth: 0,
          margin: EdgeInsets.zero,
          primaryXAxis: DateTimeAxis(
            isVisible: true,
            labelStyle: const TextStyle(
              fontSize: 8,
              fontFamily: 'Roboto',
              color: AppColors.textMuted,
            ),
            dateFormat: DateFormat.Hm(),
            majorGridLines: const MajorGridLines(width: 0),
            axisLine: const AxisLine(width: 0),
            edgeLabelPlacement: EdgeLabelPlacement.shift,
          ),
          primaryYAxis: NumericAxis(
            isVisible: true,
            labelStyle: const TextStyle(
              fontSize: 8,
              fontFamily: 'Roboto',
              color: AppColors.textMuted,
            ),
            majorGridLines: MajorGridLines(
              color: AppColors.border.withValues(alpha: 0.2),
              width: 1,
            ),
            axisLine: const AxisLine(width: 0),
          ),
          legend: const Legend(
            isVisible: true,
            position: LegendPosition.top,
            overflowMode: LegendItemOverflowMode.wrap,
            itemPadding: 8,
            textStyle: TextStyle(
              fontSize: 12,
              fontFamily: 'Roboto',
              color: AppColors.textSecondary,
            ),
          ),
          tooltipBehavior: TooltipBehavior(enable: true),
          series: grouped.entries.map((entry) {
            final index = grouped.keys.toList().indexOf(entry.key);
            final seriesColor = _getSeriesColor(index);

            // Filter out entries with invalid timestamps or values
            final validData = entry.value.where((m) {
              final ts = m['timestamp'];
              final val = m['value'];
              return ts is String &&
                  DateTime.tryParse(ts) != null &&
                  val is num &&
                  !val.isNaN &&
                  !val.isInfinite;
            }).toList();

            return AreaSeries<Map<String, dynamic>, DateTime>(
              dataSource: validData,
              xValueMapper: (m, _) =>
                  DateTime.parse(m['timestamp'] as String).toLocal(),
              yValueMapper: (m, _) => (m['value'] as num).toDouble(),
              name: entry.key,
              color: seriesColor,
              borderWidth: 3,
              borderColor: seriesColor,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  seriesColor.withValues(alpha: 0.5),
                  seriesColor.withValues(alpha: 0.1),
                ],
              ),
              markerSettings: MarkerSettings(
                isVisible: true,
                shape: DataMarkerType.circle,
                width: 6,
                height: 6,
                color: seriesColor,
                borderWidth: 2,
                borderColor: Colors.white,
              ),
              animationDuration: 1000,
            );
          }).toList(),
        );
      },
      loading: () =>
          const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      error: (err, stack) => _buildEmptyState(message: 'Error de conexión'),
    );
  }

  Widget _buildEmptyState({String? message}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isOnline ? Icons.auto_graph_rounded : Icons.sensors_off_rounded,
            size: 32,
            color: isOnline
                ? AppColors.primary.withValues(alpha: 0.4)
                : AppColors.negative.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 12),
          Text(
            message ?? (isOnline ? 'Esperando telemetría...' : '⚠ Sin Datos'),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          if (!isOnline && lastSeenRelative != null) ...[
            const SizedBox(height: 4),
            Text(
              'Última conexión: $lastSeenRelative',
              style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
            ),
          ],
        ],
      ),
    );
  }

  Color _getSeriesColor(int index) {
    const colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.positive,
      AppColors.warning,
      AppColors.negative,
    ];
    return colors[index % colors.length];
  }
}
