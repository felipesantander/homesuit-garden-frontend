import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:garden_homesuit/config/app_colors.dart';
import 'package:go_router/go_router.dart';

class MobileLayout extends StatelessWidget {
  final Widget child;

  const MobileLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final currentLocation = GoRouterState.of(context).matchedLocation;

    return Scaffold(
      extendBody: true,
      body: child,
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: BottomNavigationBar(
              currentIndex: _calculateSelectedIndex(currentLocation),
              onTap: (index) => _onItemTapped(context, index),
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.textSecondary.withValues(
                alpha: 0.6,
              ),
              showSelectedLabels: true,
              showUnselectedLabels: true,
              selectedLabelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard_outlined),
                  activeIcon: Icon(Icons.dashboard_rounded),
                  label: 'Dashboard',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.sensors_outlined),
                  activeIcon: Icon(Icons.sensors_rounded),
                  label: 'Canales',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.eco_outlined),
                  activeIcon: Icon(Icons.eco_rounded),
                  label: 'Jardines',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.more_horiz_rounded),
                  label: 'Más',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  int _calculateSelectedIndex(String location) {
    if (location == '/dashboard' || location == '/') return 0;
    if (location == '/channels') return 1;
    if (location == '/gardens') return 2;
    return 3; // For anything else or 'Más' related
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/channels');
        break;
      case 2:
        context.go('/gardens');
        break;
      case 3:
        _showMoreMenu(context);
        break;
    }
  }

  void _showMoreMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.precision_manufacturing_outlined,
                  color: AppColors.primary,
                ),
                title: const Text('Nuevos Sensores'),
                onTap: () {
                  context.pop();
                  context.go('/machine-candidates');
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.business_center_outlined,
                  color: AppColors.primary,
                ),
                title: const Text('Negocios'),
                onTap: () {
                  context.pop();
                  context.go('/businesses');
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.security_rounded,
                  color: AppColors.primary,
                ),
                title: const Text('Roles y Permisos'),
                onTap: () {
                  context.pop();
                  context.go('/roles-permissions');
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
