import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:garden_homesuit/config/app_colors.dart';
import 'package:garden_homesuit/providers/businesses.provider.dart';
import 'package:garden_homesuit/providers/gardens.provider.dart';
import 'package:garden_homesuit/providers/dashboard_filters.provider.dart';

class GlobalFiltersComponent extends HookConsumerWidget {
  const GlobalFiltersComponent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Global State
    final selectedBusinessIds = ref.watch(selectedBusinessIdsProvider);
    final selectedGardenIds = ref.watch(selectedGardenIdsProvider);

    // Local Pending State (for "Apply" pattern)
    final pendingBusinessIds = useState<Set<String>>(selectedBusinessIds);
    final pendingGardenIds = useState<Set<String>>(selectedGardenIds);

    // Sync local state when global state changes
    useEffect(() {
      pendingBusinessIds.value = selectedBusinessIds;
      pendingGardenIds.value = selectedGardenIds;
      return null;
    }, [selectedBusinessIds, selectedGardenIds]);

    // Data Fetching
    final businessesAsync = ref.watch(businessesProvider);
    final gardensAsync = ref.watch(gardensProvider);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Business Filter
        businessesAsync.when(
          data: (businesses) => _buildFilterMenu(
            label: 'Empresas',
            icon: Icons.business_center_rounded,
            color: AppColors.primary,
            items: businesses
                .map((b) => _FilterItem(id: b.idBusiness, name: b.name))
                .toList(),
            selectedIds: pendingBusinessIds.value,
            onChanged: (newSet) => pendingBusinessIds.value = newSet,
          ),
          loading: () => const _LoadingPlaceholder(),
          error: (error, stack) => const SizedBox(),
        ),

        const SizedBox(width: 12),

        // Garden Filter
        gardensAsync.when(
          data: (gardens) {
            // Optional: Filter gardens by selected businesses in context
            final filteredGardens = pendingBusinessIds.value.isEmpty
                ? gardens
                : gardens
                      .where(
                        (g) => pendingBusinessIds.value.contains(g.business),
                      )
                      .toList();

            return _buildFilterMenu(
              label: 'Jardines',
              icon: Icons.eco_rounded,
              color: AppColors.water,
              items: filteredGardens
                  .map((g) => _FilterItem(id: g.idGarden, name: g.name))
                  .toList(),
              selectedIds: pendingGardenIds.value,
              onChanged: (newSet) => pendingGardenIds.value = newSet,
            );
          },
          loading: () => const _LoadingPlaceholder(),
          error: (error, stack) => const SizedBox(),
        ),

        const SizedBox(width: 24),

        // Apply Button
        ElevatedButton.icon(
          onPressed: () {
            ref.read(selectedBusinessIdsProvider.notifier).state =
                pendingBusinessIds.value;
            ref.read(selectedGardenIdsProvider.notifier).state =
                pendingGardenIds.value;
          },
          icon: const Icon(Icons.filter_list_rounded, size: 18),
          label: const Text('Aplicar'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterMenu({
    required String label,
    required IconData icon,
    required Color color,
    required List<_FilterItem> items,
    required Set<String> selectedIds,
    required Function(Set<String>) onChanged,
  }) {
    return MenuAnchor(
      style: MenuStyle(
        backgroundColor: WidgetStateProperty.all(AppColors.surface),
        elevation: WidgetStateProperty.all(8),
        shadowColor: WidgetStateProperty.all(
          AppColors.shadow.withValues(alpha: 0.2),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      menuChildren: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Text(
                  'Seleccionar $label',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const Divider(height: 1),
              SizedBox(
                width: 220,
                child: CheckboxListTile(
                  value: selectedIds.isEmpty,
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  activeColor: color,
                  checkboxShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  title: const Text('Todos', style: TextStyle(fontSize: 14)),
                  onChanged: (val) {
                    if (val == true) onChanged({});
                  },
                ),
              ),
              ...items.map((item) {
                final isSelected = selectedIds.contains(item.id);
                return SizedBox(
                  width: 220,
                  child: CheckboxListTile(
                    value: isSelected,
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    activeColor: color,
                    checkboxShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    title: Text(
                      item.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: isSelected ? color : AppColors.textPrimary,
                      ),
                    ),
                    onChanged: (val) {
                      final newSet = {...selectedIds};
                      if (val == true) {
                        newSet.add(item.id);
                      } else {
                        newSet.remove(item.id);
                      }
                      onChanged(newSet);
                    },
                  ),
                );
              }),
            ],
          ),
        ),
      ],
      builder: (context, controller, child) {
        return InkWell(
          onTap: () =>
              controller.isOpen ? controller.close() : controller.open(),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selectedIds.isNotEmpty
                    ? color.withValues(alpha: 0.5)
                    : AppColors.border.withValues(alpha: 0.5),
                width: selectedIds.isNotEmpty ? 1.5 : 1.0,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(width: 8),
                Text(
                  selectedIds.isEmpty ? label : '${selectedIds.length} $label',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  controller.isOpen
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FilterItem {
  final String id;
  final String name;
  _FilterItem({required this.id, required this.name});
}

class _LoadingPlaceholder extends StatelessWidget {
  const _LoadingPlaceholder();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 42,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
      ),
      child: const Center(
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
