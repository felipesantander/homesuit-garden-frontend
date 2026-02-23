import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:garden_homesuit/components/common/action_button.component.dart';
import 'package:garden_homesuit/config/app_colors.dart';
import 'package:garden_homesuit/models/machine_candidate.model.dart';
import 'package:garden_homesuit/providers/machine_candidates.provider.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

class MachineCandidateCard extends ConsumerStatefulWidget {
  final MachineCandidate candidate;
  final VoidCallback onRegister;

  const MachineCandidateCard({
    super.key,
    required this.candidate,
    required this.onRegister,
  });

  @override
  ConsumerState<MachineCandidateCard> createState() =>
      _MachineCandidateCardState();
}

class _MachineCandidateCardState extends ConsumerState<MachineCandidateCard> {
  bool _isHovered = false;

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar candidato'),
        content: Text(
          '¿Estás seguro que deseas eliminar el candidato con serial ${widget.candidate.serial}?',
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
                  .read(machineCandidatesProvider.notifier)
                  .deleteCandidate(widget.candidate.id);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.negative),
            child: const Text('ELIMINAR'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    AppColors.surface.withValues(alpha: 0.8),
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
                      // Status and Type Icon
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: AppColors.positive,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.positive.withValues(
                                    alpha: 0.4,
                                  ),
                                  blurRadius: 4,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            _getThemeIcon(),
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                      // Actions grouped neatly
                      Row(
                        children: [
                          ActionButton(
                            icon: Icons.add_task_rounded,
                            onTap: () => context.push(
                              '/register-machine/${widget.candidate.serial}',
                            ),
                            color: AppColors.positive,
                            tooltip: 'Registrar Dispositivo',
                          ),
                          const SizedBox(width: 8),
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
                  // Friendly Name led hierarchy
                  const Text(
                    'Nuevo Dispositivo', // Friendly alias fallback
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Serial: ${widget.candidate.serial}',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: AppColors.textMuted,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Sensor Tags with soft theme colors
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.candidate.types
                        .map((type) => _SensorTag(type: type))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  // Footer info
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 14,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Visto por última vez: ${widget.candidate.discoveredAt != null ? DateFormat('HH:mm').format(widget.candidate.discoveredAt!) : '--:--'}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w500,
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

  IconData _getThemeIcon() {
    final types = widget.candidate.types.join(',').toLowerCase();
    if (types.contains('volt') || types.contains('batt')) {
      return Icons.electric_bolt_rounded;
    }
    if (types.contains('temp') || types.contains('humi')) {
      return Icons.thermostat_rounded;
    }
    return Icons.eco_rounded;
  }
}

class _SensorTag extends StatelessWidget {
  final String type;
  const _SensorTag({required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
      ),
      child: Text(
        type.toUpperCase(),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: AppColors.secondaryHover,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
