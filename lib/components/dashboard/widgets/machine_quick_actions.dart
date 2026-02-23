import 'package:flutter/material.dart';
import 'package:garden_homesuit/config/app_colors.dart';

class MachineQuickActions extends StatelessWidget {
  final bool isVisible;
  final VoidCallback? onView;
  final VoidCallback? onConfig;
  final VoidCallback? onDelete;

  const MachineQuickActions({
    super.key,
    required this.isVisible,
    this.onView,
    this.onConfig,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isVisible ? 1.0 : 0.0,
      child: Row(
        children: [
          _ActionButton(
            icon: Icons.visibility_rounded,
            label: 'Ver',
            onPressed: onView ?? () {},
          ),
          const SizedBox(width: 8),
          _ActionButton(
            icon: Icons.settings_rounded,
            label: 'Config',
            onPressed: onConfig ?? () {},
          ),
          const SizedBox(width: 8),
          _ActionButton(
            icon: Icons.delete_outline_rounded,
            label: 'Eliminar',
            onPressed: onDelete ?? () {},
            color: Colors.red,
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color? color;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = color ?? AppColors.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: themeColor.withValues(alpha: 0.2)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: themeColor),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: themeColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
