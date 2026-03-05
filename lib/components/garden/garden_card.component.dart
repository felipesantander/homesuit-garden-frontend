import 'package:flutter/material.dart';
import 'package:garden_homesuit/components/common/action_button.component.dart';
import 'package:garden_homesuit/config/app_colors.dart';
import 'package:garden_homesuit/models/business.model.dart';
import 'package:garden_homesuit/models/garden.model.dart';
import 'package:garden_homesuit/providers/businesses.provider.dart';
import 'package:garden_homesuit/providers/gardens.provider.dart';
import 'package:garden_homesuit/providers/machines.provider.dart';
import 'package:garden_homesuit/providers/auth.provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'dart:ui';

class GardenCard extends ConsumerStatefulWidget {
  final Garden garden;
  final VoidCallback onEdit;

  const GardenCard({super.key, required this.garden, required this.onEdit});

  @override
  ConsumerState<GardenCard> createState() => _GardenCardState();
}

class _GardenCardState extends ConsumerState<GardenCard> {
  bool _isHovered = false;

  String _toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Jardín'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿Estás seguro que deseas eliminar el jardín "${_toTitleCase(widget.garden.name)}"?',
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.negative.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.negative,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Se perderá permanentemente el historial de datos de todos los sensores asociados a este jardín.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.negative,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCELAR'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await ref
                  .read(gardensProvider.notifier)
                  .deleteGarden(widget.garden.idGarden);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.negative),
            child: const Text('ELIMINAR PERMANENTEMENTE'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final businessesAsync = ref.watch(businessesProvider);
    final machinesAsync = ref.watch(machinesProvider);

    // Filter sensor count
    final sensorCount = machinesAsync.when(
      data: (machines) =>
          machines.where((m) => m.garden == widget.garden.idGarden).length,
      loading: () => 0,
      error: (err, stack) => 0,
    );

    // Mock status for visual demonstration (Eco-Glassmorphism)
    // In a real scenario, this would come from a status service or aggregate telemetry
    final isHealthy =
        sensorCount > 0; // Simple logic: if has sensors, it's alive
    final statusColor = isHealthy ? AppColors.secondary : AppColors.textMuted;
    final statusBgColor = isHealthy
        ? AppColors.secondarySoft
        : Colors.grey.withValues(alpha: 0.1);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _isHovered ? -4 : 0, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : AppColors.shadow.withValues(alpha: 0.1),
              blurRadius: _isHovered ? 20 : 10,
              offset: Offset(0, _isHovered ? 12 : 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _isHovered
                      ? AppColors.primary.withValues(alpha: 0.3)
                      : AppColors.border.withValues(alpha: 0.5),
                  width: 1.5,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    isHealthy
                        ? AppColors.secondarySoft.withValues(alpha: 0.2)
                        : AppColors.surface.withValues(alpha: 0.8),
                    AppColors.surface.withValues(alpha: 0.4),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: statusBgColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.local_florist_rounded,
                              color: statusColor,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Jardín',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          if (ref
                                  .watch(authStateProvider)
                                  ?.components
                                  .contains('gardens_see') ??
                              false)
                            ActionButton(
                              icon: Icons.insights_rounded,
                              onTap: () {
                                // Action to view graphs (Quick Access)
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Abriendo gráficas detalladas...',
                                    ),
                                  ),
                                );
                              },
                              color: AppColors.secondary,
                              tooltip: 'Ver Métricas',
                            ),
                          const SizedBox(width: 4),
                          if (ref
                                  .watch(authStateProvider)
                                  ?.components
                                  .contains('gardens_config') ??
                              false)
                            ActionButton(
                              icon: Icons.edit_outlined,
                              onTap: widget.onEdit,
                              color: AppColors.primary,
                              tooltip: 'Editar',
                            ),
                          const SizedBox(width: 4),
                          if (ref
                                  .watch(authStateProvider)
                                  ?.components
                                  .contains('gardens_delete') ??
                              false)
                            ActionButton(
                              icon: Icons.delete_outline_rounded,
                              onTap: _showDeleteConfirmation,
                              color: AppColors.negative,
                              tooltip: 'Eliminar',
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _toTitleCase(widget.garden.name),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.sensors_rounded,
                        size: 14,
                        color: isHealthy
                            ? AppColors.secondary
                            : AppColors.textMuted,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$sensorCount ${sensorCount == 1 ? 'Sensor activo' : 'Sensores activos'}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isHealthy
                              ? AppColors.secondary
                              : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Divider(height: 24),
                  Row(
                    children: [
                      const Icon(
                        Icons.business_center_outlined,
                        size: 14,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: businessesAsync.when(
                          data: (businesses) {
                            final b = businesses.firstWhere(
                              (b) => b.idBusiness == widget.garden.business,
                              orElse: () =>
                                  Business(idBusiness: '', name: 'No Business'),
                            );
                            return Text(
                              b.name,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          },
                          loading: () =>
                              const Text('...', style: TextStyle(fontSize: 12)),
                          error: (err, stack) => Text(
                            widget.garden.business,
                            style: const TextStyle(fontSize: 11),
                          ),
                        ),
                      ),
                      const Text(
                        'Santiago, CL',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
