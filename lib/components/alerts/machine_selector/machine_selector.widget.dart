import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../config/app_colors.dart';
import '../../../../models/machine.model.dart';
import '../../../../providers/machines.provider.dart';

class MachineSelectorWidget extends ConsumerStatefulWidget {
  final List<String> selectedMachines;
  final ValueChanged<List<String>> onChanged;

  const MachineSelectorWidget({
    super.key,
    required this.selectedMachines,
    required this.onChanged,
  });

  @override
  ConsumerState<MachineSelectorWidget> createState() =>
      _MachineSelectorWidgetState();
}

class _MachineSelectorWidgetState extends ConsumerState<MachineSelectorWidget> {
  String _machineSearchQuery = '';

  @override
  Widget build(BuildContext context) {
    final machinesAsync = ref.watch(machinesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Máquinas Aplicables',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 12),
        machinesAsync.when<Widget>(
          data: (List<Machine> machines) {
            final filtered = machines
                .where(
                  (Machine m) => m.name.toLowerCase().contains(
                    _machineSearchQuery.toLowerCase(),
                  ),
                )
                .toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  onChanged: (v) => setState(() => _machineSearchQuery = v),
                  decoration: InputDecoration(
                    hintText: 'Buscar máquinas...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _machineSearchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () =>
                                setState(() => _machineSearchQuery = ''),
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
                if (widget.selectedMachines.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Seleccionadas:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.selectedMachines.map((String id) {
                      final m = machines
                          .where((Machine m) => m.id == id)
                          .firstOrNull;
                      if (m == null) return const SizedBox.shrink();
                      return Chip(
                        label: Text(
                          m.name,
                          style: const TextStyle(fontSize: 12),
                        ),
                        onDeleted: () {
                          final newList = List<String>.from(
                            widget.selectedMachines,
                          )..remove(id);
                          widget.onChanged(newList);
                        },
                        backgroundColor: AppColors.primary.withValues(
                          alpha: 0.1,
                        ),
                        deleteIconColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 16),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, idx) {
                      final m = filtered[idx];
                      final isSelected = widget.selectedMachines.contains(m.id);
                      return ListTile(
                        title: Text(
                          m.name,
                          style: const TextStyle(fontSize: 14),
                        ),
                        trailing: isSelected
                            ? const Icon(
                                Icons.check_circle,
                                color: AppColors.primary,
                                size: 20,
                              )
                            : const Icon(Icons.add_circle_outline, size: 20),
                        dense: true,
                        selected: isSelected,
                        selectedTileColor: AppColors.primary.withValues(
                          alpha: 0.05,
                        ),
                        onTap: () {
                          final newList = List<String>.from(
                            widget.selectedMachines,
                          );
                          if (isSelected) {
                            newList.remove(m.id);
                          } else {
                            newList.add(m.id);
                          }
                          widget.onChanged(newList);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
          loading: () => const LinearProgressIndicator(),
          error: (Object e, StackTrace s) => Text('Error: \$e'),
        ),
      ],
    );
  }
}
