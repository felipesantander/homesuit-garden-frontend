import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:garden_homesuit/config/app_colors.dart';
import 'package:garden_homesuit/providers/permissions.provider.dart';
import 'package:garden_homesuit/models/permission.model.dart';
import 'package:garden_homesuit/providers/auth.provider.dart';

class PermissionList extends ConsumerWidget {
  const PermissionList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissionsAsync = ref.watch(permissionsProvider);
    final authData = ref.watch(authStateProvider);
    final authorizedComponents = authData?.components ?? [];
    final canAdd = authorizedComponents.contains('roles_permissions_add');

    return Column(
      children: [
        _buildToolbar(context, canAdd),
        Expanded(
          child: permissionsAsync.when(
            data: (permissions) =>
                _buildList(context, permissions, ref, authorizedComponents),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text('Error: $error')),
          ),
        ),
      ],
    );
  }

  Widget _buildToolbar(BuildContext context, bool canAdd) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Permisos del Sistema',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          if (canAdd)
            ElevatedButton.icon(
              onPressed: () => _showPermissionDialog(context, null),
              icon: const Icon(Icons.add),
              label: const Text('Nuevo Permiso'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    List<Permission> permissions,
    WidgetRef ref,
    List<String> authorizedComponents,
  ) {
    if (permissions.isEmpty) {
      return const Center(
        child: Text(
          'No hay permisos registrados',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    final canConfig = authorizedComponents.contains('roles_permissions_config');
    final canDelete = authorizedComponents.contains('roles_permissions_delete');

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: permissions.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final auth = permissions[index];
        return Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: const Icon(Icons.vpn_key, color: AppColors.primary),
            ),
            title: Text(
              auth.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${auth.endpoints.length} Endpoints, ${auth.components.length} Componentes',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (canConfig)
                  IconButton(
                    icon: const Icon(Icons.edit, color: AppColors.water),
                    onPressed: () => _showPermissionDialog(context, auth),
                  ),
                if (canDelete)
                  IconButton(
                    icon: const Icon(Icons.delete, color: AppColors.negative),
                    onPressed: () => _confirmDelete(context, ref, auth),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPermissionDialog(BuildContext context, Permission? permission) {
    if (permission == null) {
      context.push('/roles-permissions/permission/new');
    } else {
      context.push('/roles-permissions/permission/${permission.idPermission}');
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Permission permission,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Permiso'),
        content: Text(
          '¿Estás seguro de que deseas eliminar el permiso "${permission.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.negative),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      ref
          .read(permissionsProvider.notifier)
          .deletePermission(permission.idPermission);
    }
  }
}
