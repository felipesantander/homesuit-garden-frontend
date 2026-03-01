import 'package:flutter/material.dart';
import 'package:garden_homesuit/config/app_colors.dart';
import 'package:garden_homesuit/models/machine.model.dart';
import 'package:garden_homesuit/providers/data_latest.provider.dart';
import 'package:garden_homesuit/providers/data_history.provider.dart';
import 'package:garden_homesuit/providers/machines.provider.dart';
import 'package:intl/intl.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'widgets/machine_metric_chips.dart';
import 'widgets/machine_status_badge.dart';
import 'widgets/machine_history_chart.dart';
import 'widgets/machine_quick_actions.dart';

class MachineDashboardCard extends ConsumerStatefulWidget {
  final Machine machine;
  final VoidCallback? onTap;

  const MachineDashboardCard({super.key, required this.machine, this.onTap});

  @override
  ConsumerState<MachineDashboardCard> createState() =>
      _MachineDashboardCardState();
}

class _MachineDashboardCardState extends ConsumerState<MachineDashboardCard> {
  bool _isHovered = false;

  bool _isOnline(String? lastCaptureDate) {
    if (lastCaptureDate == null) return false;
    try {
      final lastCapture = DateTime.parse(lastCaptureDate);
      final difference = DateTime.now().toUtc().difference(lastCapture);
      return difference.inMinutes < 30;
    } catch (e) {
      return false;
    }
  }

  String _getRelativeTime(String? lastCaptureDate) {
    if (lastCaptureDate == null) return 'Nunca';
    try {
      final lastCapture = DateTime.parse(lastCaptureDate);
      final difference = DateTime.now().toUtc().difference(lastCapture);

      if (difference.inSeconds < 60) return 'Hace instantes';
      if (difference.inMinutes < 60) return 'Hace ${difference.inMinutes}m';
      if (difference.inHours < 24) return 'Hace ${difference.inHours}h';
      return DateFormat('dd/MM HH:mm').format(lastCapture.toLocal());
    } catch (e) {
      return '--:--';
    }
  }

  String _getFullTime(String? lastCaptureDate) {
    if (lastCaptureDate == null) return 'Sin registros';
    try {
      final lastCapture = DateTime.parse(lastCaptureDate).toLocal();
      return DateFormat('dd/MM/yyyy HH:mm:ss').format(lastCapture);
    } catch (e) {
      return '--:--';
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        content: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.border.withValues(alpha: 0.6),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.delete_sweep_rounded,
                size: 48,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                'Eliminar Sensor',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '¿Estás seguro de que deseas eliminar "${widget.machine.name}"? Esta acción no se puede deshacer.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text(
                        'CANCELAR',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('ELIMINAR'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true) {
      try {
        await ref
            .read(machinesProvider.notifier)
            .deleteMachine(widget.machine.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sensor eliminado correctamente'),
              backgroundColor: AppColors.positive,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final historyDataAsync = ref.watch(
      historicalDataProvider(widget.machine.id),
    );
    final latestDataAsync = ref.watch(
      latestDataProvider(widget.machine.serial),
    );

    final String? lastCaptureDate =
        latestDataAsync.asData?.value.values.firstOrNull?['t'];
    final bool isOnline = _isOnline(lastCaptureDate);
    final String relativeTime = _getRelativeTime(lastCaptureDate);
    final String fullTime = _getFullTime(lastCaptureDate);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0, _isHovered ? -4 : 0, 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: isOnline
                    ? AppColors.positive.withValues(alpha: 0.2)
                    : _isHovered
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : AppColors.shadow.withValues(alpha: 0.1),
                blurRadius: _isHovered ? 25 : 12,
                offset: Offset(0, _isHovered ? 12 : 6),
                spreadRadius: isOnline ? 2 : 0,
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: _isHovered
                    ? AppColors.primary.withValues(alpha: 0.4)
                    : AppColors.border.withValues(alpha: 0.6),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(isOnline, relativeTime, fullTime),
                const SizedBox(height: 12),
                if (latestDataAsync.asData?.value != null) ...[
                  MachineMetricChips(
                    data: latestDataAsync.asData!.value,
                    machine: widget.machine,
                  ),
                  const SizedBox(height: 12),
                ],
                Expanded(
                  child: MachineHistoryChart(
                    historyData: historyDataAsync,
                    isOnline: isOnline,
                    lastSeenRelative: relativeTime,
                    relativeTime: relativeTime,
                  ),
                ),
                if (_isHovered) const SizedBox(height: 12),
                MachineQuickActions(
                  isVisible: _isHovered,
                  onView: () =>
                      context.push('/dashboard/machine/${widget.machine.id}'),
                  onConfig: () => context.push(
                    '/register-machine/${widget.machine.serial}',
                  ),
                  onDelete: () => _confirmDelete(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isOnline, String relativeTime, String fullTime) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.machine.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.machine.serial.toUpperCase(),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                  letterSpacing: 1.1,
                  fontFamily: 'Fira Code',
                ),
              ),
            ],
          ),
        ),
        MachineStatusBadge(
          isOnline: isOnline,
          relativeTime: relativeTime,
          fullTimestamp: fullTime,
        ),
      ],
    );
  }
}
