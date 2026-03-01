import 'package:flutter/material.dart';
import 'package:garden_homesuit/config/app_colors.dart';

class IconUtils {
  static const Map<String, IconData> iconMap = {
    'sensors': Icons.sensors_rounded,
    'thermostat': Icons.thermostat_rounded,
    'water_drop': Icons.water_drop_rounded,
    'light_mode': Icons.light_mode_rounded,
    'opacity': Icons.opacity_rounded,
    'air': Icons.air_rounded,
    'grass': Icons.grass_rounded,
    'eco': Icons.eco_rounded,
    'filter_vintage': Icons.filter_vintage_rounded,
    'sunny': Icons.sunny,
    'cloud': Icons.cloud_rounded,
    'thunderstorm': Icons.thunderstorm_rounded,
    'opacity_outlined': Icons.opacity_outlined,
    'speed': Icons.speed_rounded,
    'timer': Icons.timer_rounded,
    'bolt': Icons.bolt_rounded,
    'settings_input_antenna': Icons.settings_input_antenna_rounded,
    'waves': Icons.waves_rounded,
    'science': Icons.science_rounded,
    'psychology': Icons.psychology_rounded,
    'electric_bolt': Icons.electric_bolt_rounded,
    'electrical_services': Icons.electrical_services_rounded,
    'power': Icons.power_rounded,
    'settings_remote': Icons.settings_remote_rounded,
    'router': Icons.router_rounded,
    'wifi': Icons.wifi_rounded,
    'battery_charging_full': Icons.battery_charging_full_rounded,
    'solar_power': Icons.solar_power_rounded,
  };

  static IconData getIcon(String name) {
    return iconMap[name] ?? Icons.sensors_rounded;
  }

  /// Robustly find an icon based on name or type
  static IconData getIconForNameOrType(String? name, String? type) {
    if (name != null && name.isNotEmpty) {
      // Direct map match
      if (iconMap.containsKey(name.toLowerCase())) {
        return iconMap[name.toLowerCase()]!;
      }

      // Fuzzy name match
      final lowerName = name.toLowerCase();
      if (lowerName.contains('temp')) return Icons.thermostat_rounded;
      if (lowerName.contains('hum')) return Icons.opacity_rounded;
      if (lowerName.contains('pres')) return Icons.speed_rounded;
      if (lowerName.contains('volt')) return Icons.electric_bolt_rounded;
      if (lowerName.contains('curr')) return Icons.electrical_services_rounded;
      if (lowerName.contains('power') || lowerName.contains('pwr')) {
        return Icons.bolt_rounded;
      }
      if (lowerName.contains('flow')) return Icons.waves_rounded;
      if (lowerName.contains('light')) return Icons.light_mode_rounded;
      if (lowerName.contains('batt')) {
        return Icons.battery_charging_full_rounded;
      }
      if (lowerName.contains('wifi')) return Icons.wifi_rounded;
    }

    // Type-based match as fallback
    if (type != null && type.isNotEmpty) {
      switch (type) {
        case 'Power':
        case 'P':
          return Icons.bolt_rounded;
        case 'A':
          return Icons.electrical_services_rounded;
        case 'L':
          return Icons.opacity_rounded;
        case 'T':
          return Icons.thermostat_rounded;
        case 'V':
          return Icons.electric_bolt_rounded;
      }
    }

    return Icons.analytics_rounded;
  }

  /// Get a representative color for a channel based on name or type
  static Color getColorForNameOrType(String? name, String? type) {
    if (name != null && name.isNotEmpty) {
      final lowerName = name.toLowerCase();
      if (lowerName.contains('temp')) return Colors.orange;
      if (lowerName.contains('hum')) return Colors.cyan;
      if (lowerName.contains('pres')) return Colors.blue;
      if (lowerName.contains('volt') || lowerName.contains('curr')) {
        return Colors.yellow.shade800;
      }
      if (lowerName.contains('power') || lowerName.contains('pwr')) {
        return Colors.orangeAccent;
      }
      if (lowerName.contains('flow')) return Colors.blueAccent;
      if (lowerName.contains('light')) return Colors.amber;
      if (lowerName.contains('batt')) return Colors.green;
      if (lowerName.contains('wifi')) return Colors.indigoAccent;
    }

    if (type != null && type.isNotEmpty) {
      switch (type) {
        case 'Power':
        case 'P':
          return Colors.orangeAccent;
        case 'A':
          return Colors.yellow.shade800;
        case 'L':
          return Colors.cyan;
        case 'T':
          return Colors.orange;
        case 'V':
          return Colors.yellow.shade800;
      }
    }

    return AppColors.primary;
  }

  static List<String> getAvailableIcons() {
    return iconMap.keys.toList();
  }
}
