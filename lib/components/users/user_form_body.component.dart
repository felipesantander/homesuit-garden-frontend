import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:garden_homesuit/config/app_colors.dart';
import 'package:garden_homesuit/models/user.model.dart';
import 'package:garden_homesuit/providers/users.provider.dart';
import 'package:garden_homesuit/providers/roles.provider.dart';
import 'package:garden_homesuit/providers/businesses.provider.dart';
import 'package:garden_homesuit/styles/input_styles.dart';
import 'package:go_router/go_router.dart';

class UserFormBody extends HookConsumerWidget {
  final UserModel? user;

  const UserFormBody({super.key, this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final usernameController = useTextEditingController(text: user?.username);
    final passwordController = useTextEditingController();
    final emailController = useTextEditingController(text: user?.email);
    final firstNameController = useTextEditingController(text: user?.firstName);
    final lastNameController = useTextEditingController(text: user?.lastName);

    // Using string matching roleName to idRole could be tricky,
    // but the API roles mostly return id_role. If user model has no id_role,
    // it will be null initially unless we matched it.
    final selectedRoleId = useState<String?>(null);

    // Business ID assignment using a list instead of a single string
    // We initialize it with the current user business IDs if available
    final selectedBusinessIds = useState<List<String>>(
      user?.businessIds.toList() ?? [],
    );

    final isSubmitting = useState(false);

    final rolesAsync = ref.watch(rolesProvider);
    final businessesAsync = ref.watch(businessesProvider);

    // Initial load: Attempt to match the role if user comes with a roleName
    useEffect(() {
      if (user != null && user!.roleName != null) {
        rolesAsync.whenData((roles) {
          try {
            final matchingRole = roles.firstWhere(
              (r) => r.name == user!.roleName,
            );
            selectedRoleId.value = matchingRole.idRole;
          } catch (_) {}
        });
      }
      return null;
    }, [rolesAsync.value]);

    Future<void> saveUser() async {
      if (!formKey.currentState!.validate()) return;
      isSubmitting.value = true;

      try {
        final data = {
          'username': usernameController.text.trim(),
          'email': emailController.text.trim(),
          'first_name': firstNameController.text.trim(),
          'last_name': lastNameController.text.trim(),
        };

        if (passwordController.text.isNotEmpty) {
          data['password'] = passwordController.text;
        }

        if (user == null) {
          // Creating new user doesn't return the ID cleanly unless provider returns it.
          // Wait, the currently implemented `createUser` in UsersNotifier doesn't return the ID, it returns void!
          // We will update the `UsersNotifier` to return the new User or directly handle the connection there.
          // Actually, let's update `UsersNotifier.createUser` to return the `UserModel`. We will need to do that separately.
          await ref
              .read(usersProvider.notifier)
              .createUserWithConnection(
                userData: data,
                roleId: selectedRoleId.value,
                businessIds: selectedBusinessIds.value,
              );
        } else {
          await ref
              .read(usersProvider.notifier)
              .updateUserWithConnection(
                userId: user!.id,
                userData: data,
                roleId: selectedRoleId.value,
                businessIds: selectedBusinessIds.value,
                idUserBusinesses: user!.idUserBusinesses,
                oldBusinessIds: user!.businessIds,
              );
        }

        if (context.mounted) {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                user == null ? 'Usaurio creado' : 'Usuario actualizado',
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
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Sección: Información Personal
          const _SectionHeader(
            title: 'Información Personal',
            icon: Icons.person_pin_rounded,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: firstNameController,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: AppInputStyles.glass(
                    labelText: 'Nombres',
                    prefixIcon: const Icon(
                      Icons.badge_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: TextFormField(
                  controller: lastNameController,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: AppInputStyles.glass(
                    labelText: 'Apellidos',
                    prefixIcon: const Icon(
                      Icons.badge_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: emailController,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            keyboardType: TextInputType.emailAddress,
            decoration: AppInputStyles.glass(
              labelText: 'Correo Electrónico',
              prefixIcon: const Icon(
                Icons.email_outlined,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 48),

          // Sección: Credenciales de Acceso
          const _SectionHeader(
            title: 'Credenciales de Acceso',
            icon: Icons.vpn_key_rounded,
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  controller: usernameController,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: AppInputStyles.glass(
                    labelText: 'Username',
                    prefixIcon: const Icon(
                      Icons.person_outline,
                      color: AppColors.primary,
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Requerido';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: passwordController,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      obscureText: true,
                      decoration: AppInputStyles.glass(
                        labelText: 'Contraseña',
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: AppColors.primary,
                        ),
                      ),
                      validator: (val) {
                        if (user == null &&
                            (val == null || val.trim().isEmpty)) {
                          return 'Requerido para nuevos usuarios';
                        }
                        return null;
                      },
                    ),
                    if (user != null)
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0, left: 16.0),
                        child: Text(
                          'Déjalo en blanco si no deseas actualizar tu contraseña actual.',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 48),

          // Sección: Permisos de Sistema
          const _SectionHeader(
            title: 'Permisos y Accesos',
            icon: Icons.admin_panel_settings_rounded,
          ),
          const SizedBox(height: 24),
          rolesAsync.when(
            data: (roles) {
              return DropdownButtonFormField<String>(
                initialValue: selectedRoleId.value,
                dropdownColor: AppColors.surface,
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.primary,
                ),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                decoration: AppInputStyles.glass(
                  labelText: 'Asignar Rol (Opcional)',
                  prefixIcon: const Icon(
                    Icons.security_outlined,
                    color: AppColors.primary,
                  ),
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text(
                      'Sin rol',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                  ...roles.map(
                    (role) => DropdownMenuItem(
                      value: role.idRole,
                      child: Text(role.name),
                    ),
                  ),
                ],
                onChanged: (val) => selectedRoleId.value = val,
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Text(
              'Error cargando roles: $err',
              style: const TextStyle(color: AppColors.negative),
            ),
          ),
          const SizedBox(height: 20),
          businessesAsync.when(
            data: (businesses) {
              if (businesses.isEmpty) {
                return const Text(
                  'No hay negocios disponibles',
                  style: TextStyle(color: AppColors.textSecondary),
                );
              }
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.border.withValues(alpha: 0.4),
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: ExpansionTile(
                  collapsedBackgroundColor: Colors.transparent,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.05),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  iconColor: AppColors.primary,
                  collapsedIconColor: AppColors.textSecondary,
                  leading: const Icon(
                    Icons.business_outlined,
                    color: AppColors.primary,
                  ),
                  title: const Text(
                    'Asignar Negocios (Opcional)',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    '${selectedBusinessIds.value.length} Negocios seleccionados',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  childrenPadding: const EdgeInsets.all(20),
                  expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 250),
                      child: SingleChildScrollView(
                        child: Wrap(
                          spacing: 10.0,
                          runSpacing: 10.0,
                          children: businesses.map((bus) {
                            final isSelected = selectedBusinessIds.value
                                .contains(bus.idBusiness);
                            return FilterChip(
                              label: Text(bus.name),
                              selected: isSelected,
                              side: BorderSide(
                                color: isSelected
                                    ? AppColors.primary.withValues(alpha: 0.5)
                                    : AppColors.border.withValues(alpha: 0.3),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              onSelected: (bool selected) {
                                final currentList = List<String>.from(
                                  selectedBusinessIds.value,
                                );
                                if (selected) {
                                  currentList.add(bus.idBusiness);
                                } else {
                                  currentList.remove(bus.idBusiness);
                                }
                                selectedBusinessIds.value = currentList;
                              },
                              selectedColor: AppColors.primary.withValues(
                                alpha: 0.2,
                              ),
                              checkmarkColor: AppColors.primary,
                              labelStyle: TextStyle(
                                fontSize: 13,
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
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Text(
              'Error cargando negocios: $err',
              style: const TextStyle(color: AppColors.negative),
            ),
          ),
          const SizedBox(height: 64),

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
                  onPressed: isSubmitting.value ? null : saveUser,
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
                          user == null ? 'CREAR USUARIO' : 'GUARDAR CAMBIOS',
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
