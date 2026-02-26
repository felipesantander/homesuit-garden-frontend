import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:garden_homesuit/components/machine_candidate/register_machine_channels.component.dart';
import 'package:garden_homesuit/components/machine_candidate/register_machine_identifiers.component.dart';
import 'package:garden_homesuit/components/machine_candidate/register_machine_frequencies.component.dart';
import 'package:garden_homesuit/models/machine_candidate.model.dart';
import 'package:garden_homesuit/services/machine.service.dart';
import 'package:garden_homesuit/providers/auth.provider.dart';
import 'package:garden_homesuit/providers/channels.provider.dart';
import 'package:garden_homesuit/providers/gardens.provider.dart';
import 'package:garden_homesuit/providers/businesses.provider.dart';
import 'package:garden_homesuit/views/web/machine_candidates/register_machine.view.dart';
import 'package:garden_homesuit/providers/machines.provider.dart';
import 'package:garden_homesuit/providers/configuration_channels.provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class RegisterMachineForm extends HookConsumerWidget {
  final MachineCandidate candidate;
  final VoidCallback onSaved;

  const RegisterMachineForm({
    super.key,
    required this.candidate,
    required this.onSaved,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final machines = ref.watch(machinesProvider).value ?? [];
    final existingMachine = machines
        .where((m) => m.serial == candidate.serial)
        .firstOrNull;

    final nameController = useTextEditingController(
      text: existingMachine?.name,
    );
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final channelsAsync = ref.watch(channelsProvider);
    final gardensAsync = ref.watch(gardensProvider);
    final businessesAsync = ref.watch(businessesProvider);

    final selectedGarden = useState<String?>(existingMachine?.garden);
    final channelMappings = useState<Map<String, String>>(
      existingMachine?.channelMappings ?? {},
    );
    final supportedFrequencies = useState<List<String>>(
      existingMachine?.supportedFrequencies.isNotEmpty == true
          ? existingMachine!.supportedFrequencies
          : ['1_minutes'],
    );
    final dashboardFrequency = useState<String?>(
      (existingMachine?.dashboardFrequency != null &&
              supportedFrequencies.value.contains(
                existingMachine!.dashboardFrequency,
              ))
          ? existingMachine.dashboardFrequency
          : (supportedFrequencies.value.isNotEmpty
                ? supportedFrequencies.value.first
                : '1_minutes'),
    );

    final configurationChannelsAsync = ref.watch(configurationChannelsProvider);

    // Sync state when existingMachine or detailed configurations arrive/change
    useEffect(() {
      Future.microtask(() {
        if (!context.mounted) return;

        // 1. Sync Name and Garden if needed
        if (existingMachine != null) {
          if (nameController.text.isEmpty) {
            nameController.text = existingMachine.name;
          }
          if (selectedGarden.value == null) {
            selectedGarden.value = existingMachine.garden;
          }
          if (supportedFrequencies.value.length == 1 &&
              supportedFrequencies.value.first == '1_minutes' &&
              existingMachine.supportedFrequencies.isNotEmpty) {
            supportedFrequencies.value = existingMachine.supportedFrequencies;
          }
        }

        // 2. Resolve robust channel mappings from multiple sources
        final Map<String, String> resolvedMappings = Map.from(
          channelMappings.value,
        );
        bool changed = false;

        // From existing machine object (basic mappings)
        if (existingMachine?.channelMappings != null) {
          for (final entry in existingMachine!.channelMappings!.entries) {
            if (!resolvedMappings.containsKey(entry.key)) {
              resolvedMappings[entry.key] = entry.value;
              changed = true;
            }
          }
        }

        // From detailed configuration channels service
        final configList = configurationChannelsAsync.value;
        if (configList != null) {
          for (final item in configList) {
            if (item['serial'] == candidate.serial) {
              final type = item['type']?.toString();
              var channelRaw =
                  item['channel'] ?? item['idChannel'] ?? item['id_channel'];

              if (channelRaw is Map) {
                channelRaw =
                    channelRaw['idChannel'] ??
                    channelRaw['id_channel'] ??
                    channelRaw['id'] ??
                    channelRaw['uuid'];
              }

              final channelId = channelRaw?.toString();
              if (type != null &&
                  channelId != null &&
                  !resolvedMappings.containsKey(type)) {
                resolvedMappings[type] = channelId;
                changed = true;
              }
            }
          }
        }

        if (changed) {
          channelMappings.value = resolvedMappings;
        }
      });
      return null;
    }, [existingMachine, configurationChannelsAsync.value]);

    final handleSave = useCallback(
      () async {
        if (!formKey.currentState!.validate()) return;

        ref.read(registerMachineLoadingProvider.notifier).state = true;
        try {
          final authState = ref.read(authStateProvider);
          final service = MachineService(
            token: authState?.access ?? '',
            onUnauthorized: () =>
                ref.read(authStateProvider.notifier).clearAuthState(),
          );

          // Atomic Registration
          await service.register(
            serial: candidate.serial,
            name: nameController.text,
            supportedFrequencies: supportedFrequencies.value,
            dashboardFrequency:
                dashboardFrequency.value ?? supportedFrequencies.value.first,
            gardenId: selectedGarden.value,
            configurations: channelMappings.value.entries
                .map((e) => {'type': e.key, 'channel': e.value})
                .toList(),
          );

          onSaved();
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error al registrar máquina: $e')),
            );
          }
        } finally {
          if (ref.read(registerMachineLoadingProvider.notifier).mounted) {
            ref.read(registerMachineLoadingProvider.notifier).state = false;
          }
        }
      },
      [
        candidate.serial,
        onSaved,
        selectedGarden.value,
        channelMappings.value,
        ref,
      ],
    );

    useEffect(() {
      final notifier = ref.read(registerMachineSaveProvider.notifier);
      Future.microtask(() {
        if (notifier.mounted) {
          notifier.state = handleSave;
        }
      });
      return null;
    }, [handleSave, ref]);

    return Form(
      key: formKey,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMultiColumn = constraints.maxWidth > 450;

          final identifiersCol = RegisterMachineIdentifiers(
            nameController: nameController,
            serial: candidate.serial,
            selectedGarden: selectedGarden.value,
            gardens: gardensAsync.value ?? [],
            businesses: businessesAsync.value ?? [],
            onGardenChanged: (val) => selectedGarden.value = val,
          );

          final frequenciesCol = RegisterMachineFrequencies(
            selectedFrequencies: supportedFrequencies.value,
            dashboardFrequency: dashboardFrequency.value,
            onFrequenciesChanged: (val) => supportedFrequencies.value = val,
            onDashboardFrequencyChanged: (val) =>
                dashboardFrequency.value = val,
          );

          final channelsCol = RegisterMachineChannels(
            types: candidate.types,
            channels: channelsAsync.value ?? [],
            businesses: businessesAsync.value ?? [],
            channelMappings: channelMappings.value,
            onChannelMappingChanged: (type, channelId) {
              final newMappings = Map<String, String>.from(
                channelMappings.value,
              );
              if (channelId != null) {
                newMappings[type] = channelId;
              } else {
                newMappings.remove(type);
              }
              channelMappings.value = newMappings;
            },
          );

          if (isMultiColumn) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      identifiersCol,
                      const SizedBox(height: 32),
                      frequenciesCol,
                    ],
                  ),
                ),
                const SizedBox(width: 32),
                Expanded(flex: 6, child: channelsCol),
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              identifiersCol,
              const SizedBox(height: 32),
              frequenciesCol,
              const SizedBox(height: 32),
              channelsCol,
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }
}
