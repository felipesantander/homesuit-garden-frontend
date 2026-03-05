import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:garden_homesuit/config/app_colors.dart';
import 'package:garden_homesuit/models/role.model.dart';
import 'package:garden_homesuit/providers/roles.provider.dart';
import 'package:garden_homesuit/providers/permissions.provider.dart';
import 'package:garden_homesuit/styles/input_styles.dart';
import 'package:go_router/go_router.dart';

class RoleFormBody extends HookConsumerWidget {
  final Role? role;

  const RoleFormBody({super.key, this.role});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final nameController = useTextEditingController(text: role?.name ?? '');
    final selectedPermissions = useState<List<String>>(
      role?.permissions.toList() ?? [],
    );
    final isSubmitting = useState(false);

    final permissionsAsync = ref.watch(permissionsProvider);

    Future<void> saveRole() async {
      if (!formKey.currentState!.validate()) return;
      isSubmitting.value = true;

      final data = {
        'name': nameController.text.trim(),
        'permissions': selectedPermissions.value,
      };

      try {
        if (role == null) {
          await ref.read(rolesProvider.notifier).createRole(data);
        } else {
          await ref.read(rolesProvider.notifier).updateRole(role!.idRole, data);
        }

        if (context.mounted) {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                role == null
                    ? 'Rol creado exitosamente'
                    : 'Rol actualizado correctamente',
              ),
              backgroundColor: AppColors.positive,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: AppColors.negative,
            ),
          );
        }
      } finally {
        if (context.mounted) {
          isSubmitting.value = false;
        }
      }
    }

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Sección: Información Básica
          const _SectionHeader(
            title: 'Información del Rol',
            icon: Icons.info_outline_rounded,
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: nameController,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            decoration: AppInputStyles.glass(
              labelText: 'Nombre del Rol',
              prefixIcon: const Icon(
                Icons.badge_outlined,
                color: AppColors.primary,
              ),
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'El nombre es requerido';
              }
              return null;
            },
          ),
          const SizedBox(height: 48),

          // Sección: Asignación de Permisos
          const _SectionHeader(
            title: 'Asignar Permisos',
            icon: Icons.lock_open_rounded,
          ),
          const SizedBox(height: 24),
          permissionsAsync.when(
            data: (permissions) {
              if (permissions.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text(
                      'No hay permisos disponibles definidos en el sistema.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                );
              }

              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.border.withValues(alpha: 0.4),
                  ),
                ),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: permissions.map((p) {
                    final isSelected = selectedPermissions.value.contains(
                      p.idPermission,
                    );
                    return FilterChip(
                      label: Text(p.name),
                      selected: isSelected,
                      onSelected: (selected) {
                        final currentList = List<String>.from(
                          selectedPermissions.value,
                        );
                        if (selected) {
                          currentList.add(p.idPermission);
                        } else {
                          currentList.remove(p.idPermission);
                        }
                        selectedPermissions.value = currentList;
                      },
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.5)
                            : AppColors.border.withValues(alpha: 0.3),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      selectedColor: AppColors.primary.withValues(alpha: 0.2),
                      checkmarkColor: AppColors.primary,
                      labelStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected
                            ? FontWeight.w900
                            : FontWeight.w600,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textPrimary,
                      ),
                    );
                  }).toList(),
                ),
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (err, _) => Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text(
                  'Error cargando permisos: $err',
                  style: const TextStyle(color: AppColors.negative),
                ),
              ),
            ),
          ),

          const SizedBox(height: 64),

          // Botones de Acción
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => context.pop(),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 24,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'CANCELAR',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: isSubmitting.value ? null : saveRole,
                  style:
                      ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 56,
                          vertical: 24,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 0,
                      ).copyWith(
                        overlayColor: WidgetStateProperty.all(
                          Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                  child: isSubmitting.value
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : Text(
                          role == null ? 'CREAR ROL' : 'GUARDAR CAMBIOS',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.1,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.border.withValues(alpha: 0.5),
                    AppColors.border.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
