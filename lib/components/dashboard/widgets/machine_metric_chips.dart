import 'package:flutter/material.dart';
import 'package:garden_homesuit/config/app_colors.dart';

class MachineMetricChips extends StatelessWidget {
  final Map<String, dynamic> data;

  const MachineMetricChips({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: data.entries.map<Widget>((e) {
        final val = (e.value as Map<String, dynamic>)['v'];
        final type = (e.value as Map<String, dynamic>)['type'] ?? '';
        final unit = (e.value as Map<String, dynamic>)['u'] ?? '';

        IconData icon;
        Color color;

        switch (type) {
          case 'Power':
            icon = Icons.bolt_rounded;
            color = Colors.orange;
            break;
          case 'A': // Current
            icon = Icons.electrical_services_rounded;
            color = AppColors.primary;
            break;
          case 'L': // Humidity
            icon = Icons.opacity_rounded;
            color = AppColors.water;
            break;
          case 'T': // Temperature
            icon = Icons.thermostat_rounded;
            color = Colors.orangeAccent;
            break;
          default:
            icon = Icons.analytics_rounded;
            color = AppColors.textSecondary;
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Text(
                '$val $unit',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
