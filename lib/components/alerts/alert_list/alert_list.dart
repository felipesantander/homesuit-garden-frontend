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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: alert.isActive
                  ? AppColors.primarySoft
                  : AppColors.background,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_active_rounded,
              color: alert.isActive
                  ? AppColors.primary
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${alert.machines.length} Máquinas · ${alert.criteria.length} Criterios · Persistencia: ${alert.duration}s',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Switch(
            value: alert.isActive,
            activeThumbColor: AppColors.primary,
            onChanged: (val) {
              ref.read(alertsProvider.notifier).toggleAlert(alert.id, val);
            },
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.edit_rounded, color: AppColors.primary),
            tooltip: 'Editar alerta',
            onPressed: () {
              context.push('/alerts/edit/${alert.id}');
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: Colors.redAccent,
            ),
            tooltip: 'Eliminar alerta',
            onPressed: () {
              ref.read(alertsProvider.notifier).deleteAlert(alert.id);
            },
          ),
        ],
      ),
    );
  }
}
