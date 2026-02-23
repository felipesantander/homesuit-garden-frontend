import 'package:flutter/material.dart';
import 'package:garden_homesuit/components/machine_candidate/type_channel_selector.component.dart';
import 'package:garden_homesuit/config/app_colors.dart';
import 'package:garden_homesuit/models/business.model.dart';
import 'package:garden_homesuit/models/channel.model.dart';

class RegisterMachineChannels extends StatelessWidget {
  final List<String> types;
  final List<Channel> channels;
  final List<Business> businesses;
  final Map<String, String> channelMappings;
  final Function(String type, String? channelId) onChannelMappingChanged;

  const RegisterMachineChannels({
    super.key,
    required this.types,
    required this.channels,
    required this.businesses,
    required this.channelMappings,
    required this.onChannelMappingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Configuración de Canales',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Asocia cada tipo detectado con un canal para la ingesta de datos.',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        ...types.map(
          (type) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TypeChannelSelector(
              type: type,
              channels: channels,
              businesses: businesses,
              onChanged: (channelId) =>
                  onChannelMappingChanged(type, channelId),
              selectedValue: channelMappings[type],
            ),
          ),
        ),
      ],
    );
  }
}
