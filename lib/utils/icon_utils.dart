import 'package:flutter/material.dart';

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
  };

  static IconData getIcon(String name) {
    return iconMap[name] ?? Icons.sensors_rounded;
  }

  static List<String> getAvailableIcons() {
    return iconMap.keys.toList();
  }
}
