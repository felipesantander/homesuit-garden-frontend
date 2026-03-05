import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:garden_homesuit/config/app_colors.dart';
import 'package:garden_homesuit/providers/roles.provider.dart';
import 'package:garden_homesuit/models/role.model.dart';
import 'package:garden_homesuit/providers/auth.provider.dart';
import 'package:go_router/go_router.dart';

class RoleList extends ConsumerWidget {
  const RoleList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rolesAsync = ref.watch(rolesProvider);
    final authData = ref.watch(authStateProvider);
    final authorizedComponents = authData?.components ?? [];
    final canAdd = authorizedComponents.contains('roles_permissions_add');

    return Column(
      children: [
        _buildToolbar(context, canAdd),
        Expanded(
          child: rolesAsync.when(
            data: (roles) =>
                _buildList(context, roles, ref, authorizedComponents),
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
            'Roles del Sistema',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          if (canAdd)
            ElevatedButton.icon(
              onPressed: () => context.push('/roles-permissions/role/new'),
              icon: const Icon(Icons.add),
              label: const Text('Nuevo Rol'),
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
    List<Role> roles,
    WidgetRef ref,
    List<String> authorizedComponents,
  ) {
    if (roles.isEmpty) {
      return const Center(
        child: Text(
          'No hay roles registrados',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    final canConfig = authorizedComponents.contains('roles_permissions_config');
    final canDelete = authorizedComponents.contains('roles_permissions_delete');

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: roles.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final role = roles[index];
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
              child: const Icon(Icons.group, color: AppColors.primary),
            ),
            title: Text(
              role.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${role.permissions.length} Permisos asignados',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (canConfig)
                  IconButton(
                    icon: const Icon(Icons.edit, color: AppColors.water),
                    onPressed: () =>
                        context.push('/roles-permissions/role/${role.idRole}'),
                  ),
                if (canDelete)
                  IconButton(
                    icon: const Icon(Icons.delete, color: AppColors.negative),
                    onPressed: () => _confirmDelete(context, ref, role),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Role role,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Rol'),
        content: Text(
          '¿Estás seguro de que deseas eliminar el rol "${role.name}"?',
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
      ref.read(rolesProvider.notifier).deleteRole(role.idRole);
    }
  }
}
