import 'package:flutter/material.dart';
import 'package:garden_homesuit/views/web/roles_permissions/role_form/components/role_form_body.dart';
import 'package:garden_homesuit/config/app_colors.dart';
import 'package:garden_homesuit/providers/roles.provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';

class RoleFormView extends ConsumerWidget {
  final String? roleId; // If null, it's a create view

  const RoleFormView({super.key, this.roleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (roleId != null) {
      final rolesAsync = ref.watch(rolesProvider);

      return rolesAsync.when(
        data: (roles) {
          final role = roles.firstWhere(
            (r) => r.idRole == roleId!,
            orElse: () => throw Exception('Rol no encontrado'),
          );

          return _buildScaffold(context, role);
        },
        loading: () => const Scaffold(
          backgroundColor: AppColors.background,
          body: Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        ),
        error: (err, stack) => Scaffold(
          backgroundColor: AppColors.background,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.negative,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error cargando rol: $err',
                  style: const TextStyle(color: AppColors.negative),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.pop(),
                  child: const Text('VOLVER'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Creating a new role
    return _buildScaffold(context, null);
  }

  Widget _buildScaffold(BuildContext context, dynamic role) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.background, AppColors.surface],
          ),
        ),
        child: Column(
          children: [
            // Hero Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    color: AppColors.primary,
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Icon(
                      role == null
                          ? Icons.security_rounded
                          : Icons.admin_panel_settings_rounded,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        role == null ? 'Nuevo Rol' : 'Editar Rol',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        role == null
                            ? 'Define un nuevo conjunto de permisos y responsabilidades'
                            : 'Ajusta el nombre y los permisos asociados a este rol',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 64,
                  vertical: 32,
                ),
                child: RoleFormBody(role: role),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
