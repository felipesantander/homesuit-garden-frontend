import 'package:flutter/material.dart';
import 'package:garden_homesuit/config/app_colors.dart';

class MachineQuickActions extends StatelessWidget {
  final bool isVisible;
  final VoidCallback? onView;
  final VoidCallback? onConfig;
  final VoidCallback? onDelete;
  final double iconSize;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  const MachineQuickActions({
    super.key,
    required this.isVisible,
    this.onView,
    this.onConfig,
    this.onDelete,
    this.iconSize = 14,
    this.fontSize = 10,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isVisible ? 1.0 : 0.0,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          if (onView != null)
            _ActionButton(
              icon: Icons.visibility_rounded,
              label: 'Ver',
              onPressed: onView!,
              iconSize: iconSize,
              fontSize: fontSize,
              padding: padding,
            ),
          if (onConfig != null)
            _ActionButton(
              icon: Icons.settings_rounded,
              label: 'Config',
              onPressed: onConfig!,
              iconSize: iconSize,
              fontSize: fontSize,
              padding: padding,
            ),
          if (onDelete != null)
            _ActionButton(
              icon: Icons.delete_outline_rounded,
              label: 'Eliminar',
              onPressed: onDelete!,
              color: Colors.red,
              iconSize: iconSize,
              fontSize: fontSize,
              padding: padding,
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
  final double iconSize;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.color,
    required this.iconSize,
    required this.fontSize,
    required this.padding,
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
          padding: padding,
          decoration: BoxDecoration(
            border: Border.all(color: themeColor.withValues(alpha: 0.2)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: iconSize, color: themeColor),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: fontSize,
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
