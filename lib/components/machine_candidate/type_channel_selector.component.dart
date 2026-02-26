import 'package:flutter/material.dart';
import 'package:garden_homesuit/config/app_colors.dart';
import 'package:garden_homesuit/models/business.model.dart';
import 'package:garden_homesuit/models/channel.model.dart';

class TypeChannelSelector extends StatelessWidget {
  final String type;
  final List<Channel> channels;
  final List<Business> businesses;
  final ValueChanged<String?> onChanged;
  final String? selectedValue;

  const TypeChannelSelector({
    super.key,
    required this.type,
    required this.channels,
    required this.businesses,
    required this.onChanged,
    this.selectedValue,
  });

  IconData _getIconForType(String type) {
    final t = type.toLowerCase();
    if (t.contains('temp')) return Icons.thermostat_rounded;
    if (t.contains('humi')) return Icons.water_drop_rounded;
    if (t.contains('volt')) return Icons.electric_bolt_rounded;
    if (t.contains('press')) return Icons.compress_rounded;
    if (t.contains('light')) return Icons.light_mode_rounded;
    return Icons.sensors_rounded;
  }

  Color _getColorForType(String type) {
    final t = type.toLowerCase();
    if (t.contains('temp')) return Colors.orange;
    if (t.contains('humi')) return Colors.blue;
    if (t.contains('volt')) return Colors.yellow.shade700;
    if (t.contains('light')) return Colors.amber;
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final typeIcon = _getIconForType(type);
    final typeColor = _getColorForType(type);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(typeIcon, size: 20, color: typeColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type.toUpperCase(),
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        fontFamily: 'Fira Code',
                      ),
                    ),
                    const Text(
                      'Hardware Detection',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),
          DropdownButtonHideUnderline(
            child: DropdownButtonFormField<String?>(
              value: selectedValue,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                filled: true,
                fillColor: AppColors.background.withValues(alpha: 0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                hintText: 'Asignar Canal',
                hintStyle: const TextStyle(fontSize: 13),
              ),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Sin Canal'),
                ),
                ...channels.map((c) {
                  final b = businesses.firstWhere(
                    (b) => b.idBusiness == c.business,
                    orElse: () => Business(idBusiness: '', name: 'No Business'),
                  );
                  final bName = b.idBusiness.isNotEmpty ? ' (${b.name})' : '';

                  return DropdownMenuItem<String?>(
                    value: c.idChannel,
                    child: Text(
                      '${c.name}$bName',
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }),
              ],
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
