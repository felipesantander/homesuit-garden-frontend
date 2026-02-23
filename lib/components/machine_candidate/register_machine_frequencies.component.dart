import 'package:flutter/material.dart';
import 'package:garden_homesuit/config/app_colors.dart';

class RegisterMachineFrequencies extends StatelessWidget {
  final List<String> selectedFrequencies;
  final String? dashboardFrequency;
  final Function(List<String>) onFrequenciesChanged;
  final Function(String?) onDashboardFrequencyChanged;

  const RegisterMachineFrequencies({
    super.key,
    required this.selectedFrequencies,
    this.dashboardFrequency,
    required this.onFrequenciesChanged,
    required this.onDashboardFrequencyChanged,
  });

  static const Map<String, String> _availableFrequencies = {
    '1_minutes': 'Cada 1 minuto',
    '5_minutes': 'Cada 5 minutos',
    '10_minutes': 'Cada 10 minutos',
    '15_minutes': 'Cada 15 minutos',
    '30_minutes': 'Cada 30 minutos',
    '45_minutes': 'Cada 45 minutos',
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'FRECUENCIAS DE REPORTE',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableFrequencies.entries.map((entry) {
            final isSelected = selectedFrequencies.contains(entry.key);
            return FilterChip(
              label: Text(
                entry.value,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                final newList = List<String>.from(selectedFrequencies);
                if (selected) {
                  newList.add(entry.key);
                } else {
                  newList.remove(entry.key);
                  if (dashboardFrequency == entry.key) {
                    onDashboardFrequencyChanged(null);
                  }
                }
                onFrequenciesChanged(newList);
              },
              selectedColor: AppColors.primary,
              checkmarkColor: Colors.white,
              backgroundColor: AppColors.surface.withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            const Text(
              'FRECUENCIA EN DASHBOARD',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(width: 8),
            Tooltip(
              message:
                  'La frecuencia seleccionada será la que se mostrará en la pestaña del dashboard principal.',
              child: Icon(
                Icons.info_outline_rounded,
                size: 16,
                color: Colors.amber.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: dashboardFrequency,
          decoration: InputDecoration(
            hintText: 'Seleccione frecuencia para vista principal',
            hintStyle: const TextStyle(
              fontSize: 14,
              color: AppColors.textMuted,
            ),
            filled: true,
            fillColor: AppColors.surface.withValues(alpha: 0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.border),
            ),
          ),
          isExpanded: true,
          items: selectedFrequencies.map((f) {
            return DropdownMenuItem(
              value: f,
              child: Text(
                _availableFrequencies[f] ?? f,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: onDashboardFrequencyChanged,
          validator: (val) => val == null ? 'Seleccione una frecuencia' : null,
        ),
      ],
    );
  }
}
