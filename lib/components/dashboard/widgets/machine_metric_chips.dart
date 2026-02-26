import 'package:flutter/material.dart';
import 'package:garden_homesuit/config/app_colors.dart';
import 'package:garden_homesuit/providers/channels.provider.dart';
import 'package:garden_homesuit/utils/icon_utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class MachineMetricChips extends ConsumerWidget {
  final Map<String, dynamic> data;

  const MachineMetricChips({super.key, required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (data.isEmpty) return const SizedBox.shrink();

    final allChannels = ref.watch(channelsProvider).value ?? [];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: data.entries.map<Widget>((e) {
        final channelId = e.key;
        final val = (e.value as Map<String, dynamic>)['v'];
        final type = (e.value as Map<String, dynamic>)['type'] ?? '';
        final unit = (e.value as Map<String, dynamic>)['u'] ?? '';

        // Try to find the channel in the model
        final channel = allChannels
            .where((c) => c.idChannel == channelId)
            .firstOrNull;

        IconData iconData;
        Color color;

        if (channel != null) {
          iconData = IconUtils.getIconForNameOrType(channel.icon, channel.name);
          try {
            color = Color(int.parse(channel.color.replaceFirst('#', '0xFF')));
          } catch (e) {
            color = AppColors.shadow;
          }
        } else {
          // Fallback to robust icon selector and color
          iconData = IconUtils.getIconForNameOrType(channelId, type);
          color = IconUtils.getColorForNameOrType(channelId, type);
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
              Icon(iconData, size: 14, color: color),
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
