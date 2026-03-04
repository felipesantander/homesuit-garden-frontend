import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../config/app_colors.dart';
import 'package:go_router/go_router.dart';
import '../../../../providers/alerts.provider.dart';
import '../../../../models/alert.model.dart';

class AlertList extends ConsumerWidget {
  const AlertList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(alertsProvider);

    return alertsAsync.when(
      data: (alerts) {
        if (alerts.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_off_outlined,
                  size: 64,
                  color: AppColors.textSecondary,
                ),
                SizedBox(height: 16),
                Text(
                  'No hay alertas configuradas',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          itemCount: alerts.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final alert = alerts[index];
            return _AlertCard(alert: alert);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }
}

class _AlertCard extends ConsumerWidget {
  final Alert alert;
  const _AlertCard({required this.alert});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Status Indicator Bar
            Container(
              width: 4,
              margin: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: alert.isActive
                    ? AppColors.primary
                    : AppColors.textSecondary.withValues(alpha: 0.2),
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(4),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    _buildIcon(),
                    const SizedBox(width: 20),
                    _buildMainInfo(),
                    _buildActions(context, ref),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: alert.isActive
            ? AppColors.primary.withValues(alpha: 0.1)
            : AppColors.textSecondary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        alert.isActive ? Icons.bolt_rounded : Icons.notifications_off_rounded,
        color: alert.isActive ? AppColors.primary : AppColors.textMuted,
        size: 28,
      ),
    );
  }

  Widget _buildMainInfo() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            alert.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildBadge(
                Icons.settings_input_component_rounded,
                '${alert.machines.length} Máquinas',
              ),
              _buildBadge(
                Icons.rule_rounded,
                '${alert.criteria.length} Criterios',
              ),
              _buildBadge(Icons.timer_rounded, '${alert.duration}s Persist.'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.textSecondary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'ACTIVA',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: AppColors.textSecondary,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 4),
            Transform.scale(
              scale: 0.8,
              child: Switch(
                value: alert.isActive,
                activeTrackColor: AppColors.primary.withValues(alpha: 0.2),
                activeColor: AppColors.primary,
                onChanged: (val) {
                  ref.read(alertsProvider.notifier).toggleAlert(alert.id, val);
                },
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),
        const VerticalDivider(width: 1, indent: 10, endIndent: 10),
        const SizedBox(width: 16),
        IconButton(
          icon: const Icon(
            Icons.edit_note_rounded,
            color: AppColors.primary,
            size: 28,
          ),
          tooltip: 'Editar alerta',
          onPressed: () => context.push('/alerts/edit/${alert.id}'),
        ),
        IconButton(
          icon: Icon(
            Icons.delete_sweep_rounded,
            color: Colors.red.withValues(alpha: 0.7),
            size: 28,
          ),
          tooltip: 'Eliminar alerta',
          onPressed: () =>
              ref.read(alertsProvider.notifier).deleteAlert(alert.id),
        ),
      ],
    );
  }
}
