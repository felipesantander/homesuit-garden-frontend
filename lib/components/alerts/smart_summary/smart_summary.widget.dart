import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../config/app_colors.dart';
import '../../../../models/alert.model.dart';
import '../../../../models/machine.model.dart';
import '../../../../models/channel.model.dart';
import '../../../../providers/machines.provider.dart';
import '../../../../providers/channels.provider.dart';

class SmartSummaryWidget extends ConsumerWidget {
  final List<String> selectedMachines;
  final List<AlertCriteria> criteria;
  final String duration;
  final List<AlertContact> contacts;

  const SmartSummaryWidget({
    super.key,
    required this.selectedMachines,
    required this.criteria,
    required this.duration,
    required this.contacts,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final channels = ref.watch(channelsProvider).value ?? <Channel>[];
    final machines = ref.watch(machinesProvider).value ?? <Machine>[];

    String summary = 'Resumen: ';

    if (selectedMachines.isEmpty) {
      summary += 'Selecciona al menos una máquina.';
    } else {
      final mNames = machines
          .where((Machine m) => selectedMachines.contains(m.id))
          .map((Machine m) => m.name)
          .toList();
      summary +=
          'En ${mNames.length == 1 ? mNames.first : '${mNames.length} máquinas'}, ';

      if (criteria.isEmpty || criteria.any((c) => c.channel.isEmpty)) {
        summary += 'configura los criterios...';
      } else {
        final critStrings = criteria
            .map((c) {
              final ch = channels
                  .where((Channel ch) => ch.idChannel == c.channel)
                  .firstOrNull;
              final name = ch?.name ?? 'Canal Único';
              final unit = ch != null && ch.unit.isNotEmpty
                  ? ' ${ch.unit}'
                  : '';
              return '$name ${c.condition} ${c.threshold}$unit';
            })
            .join(' Y ');
        summary += 'si $critStrings ';
        summary += 'por $duration seg, ';

        final validContacts = contacts
            .where((c) => c.phone.isNotEmpty)
            .toList();
        if (validContacts.isEmpty) {
          summary += 'sin contactos definidos.';
        } else {
          summary +=
              'notificar a ${validContacts.length == 1 ? validContacts.first.phone : '${validContacts.length} contactos'}.';
        }
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              summary,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontStyle: FontStyle.italic,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
