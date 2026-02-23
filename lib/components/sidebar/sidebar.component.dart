import 'package:flutter/material.dart';
import 'package:garden_homesuit/config/app_colors.dart';
import 'package:garden_homesuit/providers/sidebar_state.provider.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class Sidebar extends ConsumerWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocation = GoRouterState.of(context).matchedLocation;
    final isCollapsed = ref.watch(sidebarCollapsedProvider);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: isCollapsed ? 80 : 260,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(right: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(4, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Toggle Button & Logo
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isCollapsed ? 0 : 16),
            child: Row(
              mainAxisAlignment: isCollapsed
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.spaceBetween,
              children: [
                if (!isCollapsed)
                  Row(
                    children: [
                      Container(
                        height: 32,
                        width: 32,
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Image.asset(
                          'assets/images/garden_logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'HomeSuit',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                IconButton(
                  onPressed: () =>
                      ref.read(sidebarCollapsedProvider.notifier).toggle(),
                  icon: Icon(
                    isCollapsed ? Icons.menu_rounded : Icons.menu_open_rounded,
                    color: AppColors.primary,
                  ),
                  tooltip: isCollapsed ? 'Expandir' : 'Contraer',
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Menu Items
          _SidebarItem(
            icon: Icons.dashboard_outlined,
            label: 'Dashboard',
            isSelected:
                currentLocation == '/dashboard' || currentLocation == '/',
            onTap: () => context.go('/dashboard'),
            isCollapsed: isCollapsed,
          ),
          _SidebarItem(
            icon: Icons.precision_manufacturing_outlined,
            label: 'nuevos sensores',
            isSelected: currentLocation == '/machine-candidates',
            onTap: () => context.go('/machine-candidates'),
            isCollapsed: isCollapsed,
          ),
          _SidebarItem(
            icon: Icons.sensors_rounded,
            label: 'Canales',
            isSelected: currentLocation == '/channels',
            onTap: () => context.go('/channels'),
            isCollapsed: isCollapsed,
          ),
          _SidebarItem(
            icon: Icons.local_florist_outlined,
            label: 'Jardines',
            isSelected: currentLocation == '/gardens',
            onTap: () => context.go('/gardens'),
            isCollapsed: isCollapsed,
          ),
          _SidebarItem(
            icon: Icons.business_center_outlined,
            label: 'Negocios',
            isSelected: currentLocation == '/businesses',
            onTap: () => context.go('/businesses'),
            isCollapsed: isCollapsed,
          ),
          _SidebarItem(
            icon: Icons.security_rounded,
            label: 'Roles y Permisos',
            isSelected: currentLocation == '/roles-permissions',
            onTap: () => context.go('/roles-permissions'),
            isCollapsed: isCollapsed,
          ),
          const Spacer(),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isCollapsed;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isCollapsed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isCollapsed ? 0 : 16,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primarySoft : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: isCollapsed
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                size: 24,
              ),
              if (!isCollapsed) ...[
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
