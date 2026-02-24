import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:garden_homesuit/config/app_colors.dart';

class PermissionEntitySection<T> extends StatelessWidget {
  final AsyncValue<List<T>> dataAsync;
  final String title;
  final IconData icon;
  final List<String> selectedIds;
  final String Function(T) idExtractor;
  final String Function(T) nameExtractor;
  final void Function(T, bool) onSelected;
  final String emptyMessage;

  const PermissionEntitySection({
    super.key,
    required this.dataAsync,
    required this.title,
    required this.icon,
    required this.selectedIds,
    required this.idExtractor,
    required this.nameExtractor,
    required this.onSelected,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            dataAsync.when(
              data: (items) {
                if (items.isEmpty) {
                  return Text(emptyMessage);
                }
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: items.map((item) {
                    final id = idExtractor(item);
                    final isSelected = selectedIds.contains(id);
                    return FilterChip(
                      label: Text(nameExtractor(item)),
                      selected: isSelected,
                      onSelected: (selected) => onSelected(item, selected),
                      selectedColor: AppColors.primary.withValues(alpha: 0.1),
                    );
                  }).toList(),
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Text(
                'Error: $e',
                style: const TextStyle(color: AppColors.negative),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
