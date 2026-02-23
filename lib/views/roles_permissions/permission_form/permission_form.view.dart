import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:garden_homesuit/config/app_colors.dart';
import 'package:garden_homesuit/models/permission.model.dart';
import 'package:garden_homesuit/providers/permissions.provider.dart';
import 'package:garden_homesuit/providers/channels.provider.dart';
import 'package:garden_homesuit/providers/businesses.provider.dart';
import 'package:garden_homesuit/providers/machines.provider.dart';
import 'package:garden_homesuit/providers/gardens.provider.dart';
import 'package:garden_homesuit/models/business.model.dart';
import 'package:garden_homesuit/views/roles_permissions/permission_form/components/permission_endpoints_section.dart';
import 'package:garden_homesuit/views/roles_permissions/permission_form/components/permission_entity_section.dart';
import 'package:garden_homesuit/views/roles_permissions/permission_form/components/permission_string_list_section.dart';

class PermissionFormView extends ConsumerStatefulWidget {
  final String? permissionId;

  const PermissionFormView({super.key, this.permissionId});

  @override
  ConsumerState<PermissionFormView> createState() => _PermissionFormViewState();
}

class _PermissionFormViewState extends ConsumerState<PermissionFormView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;

  final List<PermissionEndpoint> _endpoints = [];
  final List<String> _channels = [];
  final List<String> _machines = [];
  final List<String> _gardens = [];
  final List<String> _businesses = [];
  final List<String> _components = [];

  Permission? _initialPermission;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    if (widget.permissionId != null) {
      _loadPermission();
    }
  }

  Future<void> _loadPermission() async {
    setState(() => _isLoading = true);
    try {
      final permissions = await ref.read(permissionsProvider.future);
      final permission = permissions.firstWhere(
        (p) => p.idPermission == widget.permissionId,
        orElse: () => throw Exception('Permiso no encontrado'),
      );

      setState(() {
        _initialPermission = permission;
        _nameController.text = permission.name;
        _endpoints.addAll(permission.endpoints);
        _channels.addAll(permission.channels);
        _machines.addAll(permission.machines);
        _gardens.addAll(permission.gardens);
        _businesses.addAll(permission.businesses);
        _components.addAll(permission.components);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error cargando permiso: $e')));
        context.pop();
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onBusinessSelected(Business b, bool selected) {
    setState(() {
      if (selected) {
        _businesses.add(b.idBusiness);
        // Seleccionar en cascada
        final allChannels = ref.read(channelsProvider).value ?? [];
        final allMachines = ref.read(machinesProvider).value ?? [];
        final allGardens = ref.read(gardensProvider).value ?? [];

        for (final ch in allChannels.where((c) => c.business == b.idBusiness)) {
          if (!_channels.contains(ch.idChannel)) _channels.add(ch.idChannel);
        }
        for (final m in allMachines) {
          final machineGarden = allGardens
              .where((g) => g.idGarden == m.garden)
              .firstOrNull;
          if (machineGarden?.business == b.idBusiness) {
            if (!_machines.contains(m.id)) _machines.add(m.id);
          }
        }
        for (final g in allGardens.where((g) => g.business == b.idBusiness)) {
          if (!_gardens.contains(g.idGarden)) _gardens.add(g.idGarden);
        }
      } else {
        _businesses.remove(b.idBusiness);
        // Deseleccionar en cascada
        final allChannels = ref.read(channelsProvider).value ?? [];
        final allMachines = ref.read(machinesProvider).value ?? [];
        final allGardens = ref.read(gardensProvider).value ?? [];

        for (final ch in allChannels.where((c) => c.business == b.idBusiness)) {
          _channels.remove(ch.idChannel);
        }
        for (final m in allMachines) {
          final machineGarden = allGardens
              .where((g) => g.idGarden == m.garden)
              .firstOrNull;
          if (machineGarden?.business == b.idBusiness) {
            _machines.remove(m.id);
          }
        }
        for (final g in allGardens.where((g) => g.business == b.idBusiness)) {
          _gardens.remove(g.idGarden);
        }
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'name': _nameController.text.trim(),
      'endpoints': _endpoints.map((e) => e.toJson()).toList(),
      'channels': _channels,
      'machines': _machines,
      'gardens': _gardens,
      'businesses': _businesses,
      'components': _components,
    };

    setState(() => _isLoading = true);
    try {
      if (_initialPermission == null) {
        await ref.read(permissionsProvider.notifier).createPermission(data);
      } else {
        await ref
            .read(permissionsProvider.notifier)
            .updatePermission(_initialPermission!.idPermission, data);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permiso guardado correctamente')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _initialPermission == null ? 'Nuevo Permiso' : 'Editar Permiso',
        ),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _save,
              icon: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.save),
              label: const Text('Guardar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body:
          _isLoading &&
              _initialPermission == null &&
              widget.permissionId != null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: AppColors.border),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Información General',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Nombre del Permiso',
                                border: OutlineInputBorder(),
                                filled: true,
                              ),
                              validator: (v) => v!.isEmpty ? 'Requerido' : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    PermissionEndpointsSection(
                      endpoints: _endpoints,
                      onUpdate: () => setState(() {}),
                    ),
                    const SizedBox(height: 24),
                    PermissionEntitySection(
                      dataAsync: ref.watch(businessesProvider),
                      title: 'Negocios',
                      icon: Icons.business_center_rounded,
                      selectedIds: _businesses,
                      idExtractor: (b) => b.idBusiness,
                      nameExtractor: (b) => b.name,
                      emptyMessage: 'No hay negocios disponibles.',
                      onSelected: _onBusinessSelected,
                    ),
                    const SizedBox(height: 16),
                    PermissionEntitySection(
                      dataAsync: ref.watch(channelsProvider),
                      title: 'Canales',
                      icon: Icons.sensors,
                      selectedIds: _channels,
                      idExtractor: (c) => c.idChannel,
                      nameExtractor: (c) => c.name,
                      emptyMessage: 'No hay canales disponibles.',
                      onSelected: (ch, selected) => setState(() {
                        if (selected) {
                          if (!_channels.contains(ch.idChannel)) {
                            _channels.add(ch.idChannel);
                          }
                        } else {
                          _channels.remove(ch.idChannel);
                        }
                      }),
                    ),
                    const SizedBox(height: 16),
                    PermissionEntitySection(
                      dataAsync: ref.watch(machinesProvider),
                      title: 'Máquinas',
                      icon: Icons.precision_manufacturing,
                      selectedIds: _machines,
                      idExtractor: (m) => m.id,
                      nameExtractor: (m) => m.name,
                      emptyMessage: 'No hay máquinas disponibles.',
                      onSelected: (m, selected) => setState(() {
                        if (selected) {
                          if (!_machines.contains(m.id)) {
                            _machines.add(m.id);
                          }
                        } else {
                          _machines.remove(m.id);
                        }
                      }),
                    ),
                    const SizedBox(height: 16),
                    PermissionEntitySection(
                      dataAsync: ref.watch(gardensProvider),
                      title: 'Jardines',
                      icon: Icons.local_florist,
                      selectedIds: _gardens,
                      idExtractor: (g) => g.idGarden,
                      nameExtractor: (g) => g.name,
                      emptyMessage: 'No hay jardines disponibles.',
                      onSelected: (g, selected) => setState(() {
                        if (selected) {
                          if (!_gardens.contains(g.idGarden)) {
                            _gardens.add(g.idGarden);
                          }
                        } else {
                          _gardens.remove(g.idGarden);
                        }
                      }),
                    ),
                    const SizedBox(height: 16),
                    PermissionStringListSection(
                      title: 'Componentes',
                      items: _components,
                      icon: Icons.widgets,
                      onUpdate: () => setState(() {}),
                    ),
                    const SizedBox(height: 48), // Bottom padding
                  ],
                ),
              ),
            ),
    );
  }
}
