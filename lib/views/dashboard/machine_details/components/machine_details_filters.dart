import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:garden_homesuit/config/app_colors.dart';
import 'package:garden_homesuit/models/data_query_filter.model.dart';
import 'package:garden_homesuit/models/channel.model.dart';
import 'garden_filter_chip.dart';

class MachineDetailsFilters extends ConsumerWidget {
  final DataQueryFilter filter;
  final ValueChanged<DataQueryFilter> onFilterChanged;
  final List<Channel> availableChannels;
  final List<String> supportedFrequencies;

  const MachineDetailsFilters({
    super.key,
    required this.filter,
    required this.onFilterChanged,
    required this.availableChannels,
    this.supportedFrequencies = const [],
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Filtros',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _buildDatePicker(context, 'Desde', filter.start, (date) {
              onFilterChanged(filter.copyWith(start: date?.toIso8601String()));
            }),
            _buildDatePicker(context, 'Hasta', filter.end, (date) {
              onFilterChanged(filter.copyWith(end: date?.toIso8601String()));
            }),
            _buildFrequencyDropdown(),
          ],
        ),
        if (availableChannels.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Divider(color: AppColors.border),
          const SizedBox(height: 8),
          const Text(
            'Canales',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: availableChannels.map((c) {
              final isSelected = filter.channels.contains(c.idChannel);
              return GardenFilterChip(
                label: c.name,
                isSelected: isSelected,
                onSelected: (selected) {
                  final newChannels = List<String>.from(filter.channels);
                  if (selected) {
                    newChannels.add(c.idChannel);
                  } else {
                    newChannels.remove(c.idChannel);
                  }
                  onFilterChanged(filter.copyWith(channels: newChannels));
                },
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildDatePicker(
    BuildContext context,
    String label,
    String? currentDateIso,
    ValueChanged<DateTime?> onDateSelected,
  ) {
    final currentDate = currentDateIso != null
        ? DateTime.tryParse(currentDateIso)
        : null;
    final dateDisplay = currentDate != null
        ? '${currentDate.day.toString().padLeft(2, '0')}/${currentDate.month.toString().padLeft(2, '0')}'
        : label;

    final isActive = currentDate != null;
    final color = AppColors.primary;

    return InkWell(
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: currentDate ?? now,
          firstDate: now.subtract(const Duration(days: 365 * 5)),
          lastDate: now,
        );
        onDateSelected(picked);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.15)
              : AppColors.surface.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive
                ? AppColors.primary
                : AppColors.border.withValues(alpha: 0.3),
            width: isActive ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 20,
              color: isActive ? color : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              dateDisplay,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive ? color : AppColors.textPrimary,
              ),
            ),
            if (isActive) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => onDateSelected(null),
                child: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: color.withValues(alpha: 0.8),
                ),
              ),
            ] else ...[
              const SizedBox(width: 8),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 20,
                color: AppColors.textSecondary,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFrequencyDropdown() {
    final frequencyLabels = {
      '1_minutes': '1 Min',
      '5_minutes': '5 Min',
      '10_minutes': '10 Min',
      '15_minutes': '15 Min',
      '30_minutes': '30 Min',
      '1_hours': '1 Hora',
      '2_hours': '2 Horas',
      '6_hours': '6 Horas',
      '12_hours': '12 Horas',
      '1_days': '1 Día',
      '1_weeks': '1 Sem',
      '1_months': '1 Mes',
    };

    final availableFreqs = supportedFrequencies.isNotEmpty
        ? supportedFrequencies
        : ['1_minutes', '1_hours', '1_days'];

    final displayFrequencies = <String, String>{};
    for (final freq in availableFreqs) {
      displayFrequencies[freq] =
          frequencyLabels[freq] ?? freq.replaceAll('_', ' ');
    }

    if (!displayFrequencies.containsKey(filter.frequency)) {
      displayFrequencies[filter.frequency] = filter.frequency.replaceAll(
        '_',
        ' ',
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.access_time_rounded,
            size: 20,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: filter.frequency,
              isDense: true,
              icon: const SizedBox.shrink(), // Custom icon outside
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
              items: displayFrequencies.entries.map((e) {
                return DropdownMenuItem(value: e.key, child: Text(e.value));
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  onFilterChanged(filter.copyWith(frequency: val));
                }
              },
            ),
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 20,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}
