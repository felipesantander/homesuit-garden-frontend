import 'package:flutter/material.dart';
import 'package:garden_homesuit/config/app_colors.dart';
import 'package:garden_homesuit/models/channel.model.dart';
import 'package:garden_homesuit/utils/icon_utils.dart';

class GardenFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final ValueChanged<bool> onSelected;
  final Channel? channel;

  const GardenFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onSelected,
    this.channel,
  });

  IconData _getIconForChannel(String name) {
    return IconUtils.getIconForNameOrType(channel?.icon, channel?.name ?? name);
  }

  Color _getColorForChannel(String name) {
    if (channel != null && channel!.color.isNotEmpty) {
      try {
        return Color(int.parse(channel!.color.replaceFirst('#', '0xFF')));
      } catch (e) {
        // Fallback handled below
      }
    }
    return IconUtils.getColorForNameOrType(
      channel?.icon,
      channel?.name ?? name,
    );
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
