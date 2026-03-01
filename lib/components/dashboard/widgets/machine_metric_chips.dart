import 'package:flutter/material.dart';
import 'package:garden_homesuit/config/app_colors.dart';
import 'package:garden_homesuit/providers/channels.provider.dart';
import 'package:garden_homesuit/utils/icon_utils.dart';
import 'package:garden_homesuit/models/machine.model.dart';
import 'package:garden_homesuit/providers/configuration_channels.provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class MachineMetricChips extends ConsumerWidget {
  final Map<String, dynamic> data;
  final Machine machine;

  const MachineMetricChips({
    super.key,
    required this.data,
    required this.machine,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (data.isEmpty) return const SizedBox.shrink();

    final configuredChannelsAsync = ref.watch(
      configurationChannelsByMachineProvider(machine.id),
    );

    if (configuredChannelsAsync.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    final configuredChannels = configuredChannelsAsync.value ?? [];

    // Sólo mostrar canales que estén configurados en el endpoint
    final configuredChannelIds = configuredChannels
        .expand((c) {
          final typeStr = c['type']?.toString();
          final channelData = c['channel'] ?? c['idChannel'] ?? c['id_channel'];
          String? channelUuid;
          if (channelData is Map) {
            channelUuid =
                (channelData['idChannel'] ??
                        channelData['id_channel'] ??
                        channelData['id'] ??
                        channelData['uuid'])
                    ?.toString();
          } else {
            channelUuid = channelData?.toString();
          }
          return [typeStr, channelUuid];
        })
        .whereType<String>()
        .toList();

    final filteredEntries = data.entries.where((e) {
      return configuredChannelIds.contains(e.key);
    }).toList();

    if (filteredEntries.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: filteredEntries.map<Widget>((e) {
        final entryKey = e.key;
        final val = (e.value as Map<String, dynamic>)['v'];
        final type = (e.value as Map<String, dynamic>)['type'] ?? '';
        final unit = (e.value as Map<String, dynamic>)['u'] ?? '';

        // Buscar a qué canal en la configuración corresponde esta llave (puede ser type = entryKey o channel = entryKey)
        final matchingConfig = configuredChannels.firstWhere((c) {
          final typeStr = c['type']?.toString();
          final channelData = c['channel'] ?? c['idChannel'] ?? c['id_channel'];
          String? channelUuid;
          if (channelData is Map) {
            channelUuid =
                (channelData['idChannel'] ??
                        channelData['id_channel'] ??
                        channelData['id'] ??
                        channelData['uuid'])
                    ?.toString();
          } else {
            channelUuid = channelData?.toString();
          }
          return typeStr == entryKey || channelUuid == entryKey;
        }, orElse: () => {});

        String? actualChannelId;
        final channelData =
            matchingConfig['channel'] ??
            matchingConfig['idChannel'] ??
            matchingConfig['id_channel'];
        if (channelData is Map) {
          actualChannelId =
              (channelData['idChannel'] ??
                      channelData['id_channel'] ??
                      channelData['id'] ??
                      channelData['uuid'])
                  ?.toString();
        } else {
          actualChannelId = channelData?.toString();
        }

        actualChannelId ??= entryKey;

        // Intenta obtener la info general del canal desde channelsProvider
        // usando el UUID real si es posible, o el entryKey de contingencia.
        final allChannelsList = ref.watch(channelsProvider).value ?? [];
        final channelInfo = allChannelsList
            .where((c) => c.idChannel == actualChannelId)
            .firstOrNull;

        IconData iconData;
        Color color;

        if (channelInfo != null) {
          iconData = IconUtils.getIconForNameOrType(
            channelInfo.icon,
            channelInfo.name,
          );
          try {
            color = Color(
              int.parse(channelInfo.color.replaceFirst('#', '0xFF')),
            );
          } catch (e) {
            color = AppColors.shadow;
          }
        } else {
          // Fallback
          iconData = IconUtils.getIconForNameOrType(entryKey, type);
          color = IconUtils.getColorForNameOrType(entryKey, type);
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
