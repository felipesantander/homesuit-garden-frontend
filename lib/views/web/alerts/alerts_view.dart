import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:garden_homesuit/providers/auth.provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../config/app_colors.dart';
import '../../../components/alerts/alert_list/alert_list.dart';
import '../../../components/alerts/alert_history_list/alert_history_list.dart';

class AlertsView extends ConsumerStatefulWidget {
  const AlertsView({super.key});

  @override
  ConsumerState<AlertsView> createState() => _AlertsViewState();
}

class _AlertsViewState extends ConsumerState<AlertsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddAlertForm() {
    context.push('/alerts/new');
  }

  @override
  Widget build(BuildContext context) {
    final authData = ref.watch(authStateProvider);
    final authorizedComponents = authData?.components ?? [];

    if (!authorizedComponents.contains('alerts_see')) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: Text('No tienes permiso para ver alertas')),
      );
    }

    final canAdd = authorizedComponents.contains('alerts_add');

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.background, AppColors.surface],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(canAdd),
              const SizedBox(height: 40),
              _buildTabBar(),
              const SizedBox(height: 32),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: const [AlertList(), AlertHistoryList()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool canAdd) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: const Icon(
                      Icons.shutter_speed_rounded,
                      color: AppColors.primary,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 20),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Alertas Avanzadas',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        'Monitorización inteligente y lógica de disparo personalizada',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        if (canAdd) _buildCreateButton(),
      ],
    );
  }

  Widget _buildCreateButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: _showAddAlertForm,
        icon: const Icon(Icons.add_rounded, size: 24),
        label: const Text(
          'Nueva Alerta',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.2,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      isScrollable: true,
      labelColor: Colors.white,
      unselectedLabelColor: AppColors.textSecondary,
      indicatorSize: TabBarIndicatorSize.tab,
      dividerColor: Colors.transparent,
      indicator: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.primary,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      tabs: const [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.notifications_active_outlined, size: 20),
              SizedBox(width: 10),
              Text('Alertas Activas'),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.history_rounded, size: 20),
              SizedBox(width: 10),
              Text('Historial de Ejecuciones'),
            ],
          ),
        ),
      ],
    );
  }
}
