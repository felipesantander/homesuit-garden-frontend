import 'package:flutter/material.dart';
import 'package:garden_homesuit/config/app_colors.dart';
import 'package:garden_homesuit/config/app_components.dart';

class PermissionComponentSection extends StatelessWidget {
  final List<String> selectedComponents;
  final VoidCallback onUpdate;

  const PermissionComponentSection({
    super.key,
    required this.selectedComponents,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(
          title: 'Componentes de Vista',
          icon: Icons.widgets_rounded,
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Selecciona los componentes a los que este permiso da acceso:',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: AppComponents.viewComponents.map((component) {
                  final isSelected = selectedComponents.contains(component);
                  return FilterChip(
                    label: Text(AppComponents.getDisplayName(component)),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        if (!selectedComponents.contains(component)) {
                          selectedComponents.add(component);
                        }
                      } else {
                        selectedComponents.remove(component);
                      }
                      onUpdate();
                    },
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.5)
                          : AppColors.border.withValues(alpha: 0.3),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    selectedColor: AppColors.primary.withValues(alpha: 0.2),
                    checkmarkColor: AppColors.primary,
                    labelStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.w900
                          : FontWeight.w600,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.border.withValues(alpha: 0.5),
                    AppColors.border.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
