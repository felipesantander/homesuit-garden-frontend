import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:garden_homesuit/config/app_colors.dart';
import 'package:garden_homesuit/providers/auth.provider.dart';
import 'package:go_router/go_router.dart';

import 'package:garden_homesuit/components/dashboard/machine_dashboard_card.component.dart';
import 'package:garden_homesuit/providers/machines.provider.dart';
import 'package:garden_homesuit/models/machine.model.dart';

class DashboardMobileView extends ConsumerWidget {
  const DashboardMobileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final machinesAsync = ref.watch(machinesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Garden Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => ref.read(machinesProvider.notifier).refresh(),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await ref.read(logoutActionProvider)();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: machinesAsync.when(
          data: (machines) => _MobileMachinesList(machines: machines),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => _ErrorState(error: err),
        ),
      ),
    );
  }
}

class _MobileMachinesList extends StatelessWidget {
  final List<Machine> machines;

  const _MobileMachinesList({required this.machines});

  @override
  Widget build(BuildContext context) {
    if (machines.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.eco_outlined,
              size: 64,
              color: AppColors.primary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 20),
            const Text(
              'No hay máquinas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: machines.length,
      itemBuilder: (context, index) {
        final machine = machines[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: SizedBox(
            height: 320,
            child: MachineDashboardCard(
              machine: machine,
              onTap: () {
                // Future navigation to machine details
              },
            ),
          ),
        );
      },
    );
  }
}

class _ErrorState extends StatelessWidget {
  final Object error;

  const _ErrorState({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.negative,
            ),
            const SizedBox(height: 16),
            Text(
              'Error: $error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.negative),
            ),
          ],
        ),
      ),
    );
  }
}
