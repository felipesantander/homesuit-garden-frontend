import 'package:flutter/material.dart';
import 'package:garden_homesuit/config/app_colors.dart';
import 'package:garden_homesuit/components/roles_permissions/permission_list.dart';
import 'package:garden_homesuit/components/roles_permissions/role_list.dart';

class RolesPermissionsMobileView extends StatefulWidget {
  const RolesPermissionsMobileView({super.key});

  @override
  State<RolesPermissionsMobileView> createState() =>
      _RolesPermissionsMobileViewState();
}

class _RolesPermissionsMobileViewState extends State<RolesPermissionsMobileView>
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Roles y Permisos',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'Roles'),
            Tab(text: 'Permisos'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [RoleList(), PermissionList()],
      ),
    );
  }
}
