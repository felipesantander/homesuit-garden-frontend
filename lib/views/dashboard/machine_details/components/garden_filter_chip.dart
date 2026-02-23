import 'package:flutter/material.dart';
import 'package:garden_homesuit/config/app_colors.dart';

class GardenFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final ValueChanged<bool> onSelected;

  const GardenFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  IconData _getIconForChannel(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('temp')) {
      return Icons.thermostat_rounded;
    }
    if (lowerName.contains('pres')) {
      return Icons.speed_rounded;
    }
    if (lowerName.contains('hum')) {
      return Icons.water_drop_rounded;
    }
    if (lowerName.contains('volt')) {
      return Icons.electric_bolt_rounded;
    }
    if (lowerName.contains('curr')) {
      return Icons.electrical_services_rounded;
    }
    if (lowerName.contains('flow')) {
      return Icons.waves_rounded;
    }
    return Icons.sensors_rounded;
  }

  Color _getColorForChannel(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('temp')) {
      return Colors.orange;
    }
    if (lowerName.contains('pres')) {
      return Colors.blue;
    }
    if (lowerName.contains('hum')) {
      return Colors.cyan;
    }
    if (lowerName.contains('volt') || lowerName.contains('curr')) {
      return Colors.yellow.shade800;
    }
    if (lowerName.contains('flow')) {
      return Colors.blueAccent;
    }
    return AppColors.primary;
  }

  String _normalizeLabel(String text) {
    if (text.startsWith('CH_DATA_')) {
      return text.replaceFirst('CH_DATA_', 'Canal ');
    }
    // Capitalize first letter
    if (text.isEmpty) {
      return text;
    }
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColorForChannel(label);

    return InkWell(
      onTap: () => onSelected(!isSelected),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.15)
              : AppColors.surface.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? color.withValues(alpha: 0.5)
                : AppColors.border.withValues(alpha: 0.3),
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getIconForChannel(label),
              size: 16,
              color: isSelected ? color : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              _normalizeLabel(label),
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? color : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
