import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:garden_homesuit/config/app_colors.dart';
import 'package:garden_homesuit/providers/businesses.provider.dart';

class BusinessFilter extends HookConsumerWidget {
  final Set<String> selectedIds;
  final Function(Set<String>) onApplied;

  const BusinessFilter({
    super.key,
    required this.selectedIds,
    required this.onApplied,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Local Pending State
    final pendingIds = useState<Set<String>>(selectedIds);

    // Sync local state when global state changes
    useEffect(() {
      pendingIds.value = selectedIds;
      return null;
    }, [selectedIds]);

    final businessesAsync = ref.watch(businessesProvider);

    return businessesAsync.when(
      data: (businesses) => _buildFilterMenu(
        context,
        businesses: businesses
            .map((b) => _FilterItem(id: b.idBusiness, name: b.name))
            .toList(),
        pendingIds: pendingIds,
      ),
      loading: () => const _LoadingPlaceholder(),
      error: (error, _) => const SizedBox(),
    );
  }

  Widget _buildFilterMenu(
    BuildContext context, {
    required List<_FilterItem> businesses,
    required ValueNotifier<Set<String>> pendingIds,
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
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Filtrar por Negocio',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const Divider(height: 1),
              SizedBox(
                width: 240,
                child: CheckboxListTile(
                  value: pendingIds.value.isEmpty,
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  activeColor: AppColors.primary,
                  checkboxShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  title: const Text(
                    'Todos los Negocios',
                    style: TextStyle(fontSize: 13),
                  ),
                  onChanged: (val) {
                    if (val == true) pendingIds.value = {};
                  },
                ),
              ),
              ...businesses.map((item) {
                final isSelected = pendingIds.value.contains(item.id);
                return SizedBox(
                  width: 240,
                  child: CheckboxListTile(
                    value: isSelected,
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    activeColor: AppColors.primary,
                    checkboxShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    title: Text(
                      item.name,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textPrimary,
                      ),
                    ),
                    onChanged: (val) {
                      final newSet = {...pendingIds.value};
                      if (val == true) {
                        newSet.add(item.id);
                      } else {
                        newSet.remove(item.id);
                      }
                      pendingIds.value = newSet;
                    },
                  ),
                );
              }),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => onApplied(pendingIds.value),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Aplicar Filtro',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
      builder: (context, controller, child) {
        final label = selectedIds.isEmpty
            ? 'Cualquier Negocio'
            : '${selectedIds.length} Negocios';
        return InkWell(
          onTap: () =>
              controller.isOpen ? controller.close() : controller.open(),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: selectedIds.isNotEmpty
                    ? AppColors.primary.withValues(alpha: 0.5)
                    : AppColors.border.withValues(alpha: 0.5),
                width: selectedIds.isNotEmpty ? 1.5 : 1.0,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.business_center_rounded,
                  size: 18,
                  color: selectedIds.isNotEmpty
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: selectedIds.isNotEmpty
                        ? FontWeight.w600
                        : FontWeight.w500,
                    color: selectedIds.isNotEmpty
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  controller.isOpen
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 18,
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
      width: 140,
      height: 38,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
      ),
      child: const Center(
        child: SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
