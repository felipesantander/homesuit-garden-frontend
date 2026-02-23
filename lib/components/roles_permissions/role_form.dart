import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:garden_homesuit/config/app_colors.dart';
import 'package:garden_homesuit/models/role.model.dart';
import 'package:garden_homesuit/providers/roles.provider.dart';
import 'package:garden_homesuit/providers/permissions.provider.dart';

class RoleFormDialog extends ConsumerStatefulWidget {
  final Role? role;

  const RoleFormDialog({super.key, this.role});

  @override
  ConsumerState<RoleFormDialog> createState() => _RoleFormDialogState();
}

class _RoleFormDialogState extends ConsumerState<RoleFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  final List<String> _selectedPermissions = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.role?.name ?? '');
    if (widget.role != null) {
      _selectedPermissions.addAll(widget.role!.permissions);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'name': _nameController.text.trim(),
      'permissions': _selectedPermissions,
    };

    try {
      if (widget.role == null) {
        await ref.read(rolesProvider.notifier).createRole(data);
      } else {
        await ref
            .read(rolesProvider.notifier)
            .updateRole(widget.role!.idRole, data);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authsAsync = ref.watch(permissionsProvider);

    return AlertDialog(
      title: Text(widget.role == null ? 'Nuevo Rol' : 'Editar Rol'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del Rol',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v!.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Asignar Permisos',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                authsAsync.when(
                  data: (permissions) {
                    if (permissions.isEmpty) {
                      return const Text('No hay permisos disponibles.');
                    }
                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: permissions.map((p) {
                        final isSelected = _selectedPermissions.contains(
                          p.idPermission,
                        );
                        return FilterChip(
                          label: Text(p.name),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedPermissions.add(p.idPermission);
                              } else {
                                _selectedPermissions.remove(p.idPermission);
                              }
                            });
                          },
                        );
                      }).toList(),
                    );
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (e, _) => Text('Error: $e'),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
