import 'package:flutter/material.dart';
import 'package:garden_homesuit/config/app_colors.dart';
import 'package:garden_homesuit/models/garden.model.dart';
import 'package:garden_homesuit/providers/gardens.provider.dart';
import 'package:garden_homesuit/providers/businesses.provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class GardenForm extends ConsumerStatefulWidget {
  final Garden? garden;
  final VoidCallback onSaved;

  const GardenForm({super.key, this.garden, required this.onSaved});

  @override
  ConsumerState<GardenForm> createState() => _GardenFormState();
}

class _GardenFormState extends ConsumerState<GardenForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  String? _selectedBusiness;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.garden?.name ?? '');
    _selectedBusiness = widget.garden?.business;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selectedBusiness == null) {
      if (_selectedBusiness == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, selecciona un negocio')),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (widget.garden == null) {
        await ref
            .read(gardensProvider.notifier)
            .createGarden(_nameController.text, _selectedBusiness!);
      } else {
        await ref
            .read(gardensProvider.notifier)
            .updateGarden(widget.garden!.idGarden, _nameController.text);
      }
      if (!mounted) return;
      widget.onSaved();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final businessesAsync = ref.watch(businessesProvider);

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                widget.garden == null
                    ? Icons.add_chart_rounded
                    : Icons.edit_calendar_rounded,
                color: AppColors.primary,
              ),
              const SizedBox(width: 12),
              Text(
                widget.garden == null ? 'Nuevo Jardín' : 'Editar Jardín',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Nombre del Jardín',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: 'Ej: Huerto Principal',
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.badge_outlined),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'El nombre es requerido';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          const Text(
            'Negocio Responsable',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          businessesAsync.when(
            data: (businesses) => DropdownButtonFormField<String>(
              initialValue: _selectedBusiness,
              hint: const Text('Seleccionar negocio'),
              isExpanded: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.business_center_outlined),
              ),
              items: businesses.map((business) {
                return DropdownMenuItem(
                  value: business.idBusiness,
                  child: Text(business.name),
                );
              }).toList(),
              onChanged: widget.garden == null
                  ? (value) => setState(() => _selectedBusiness = value)
                  : null, // Usually association doesn't change easily in models, but feel free to unlock if needed
              validator: (value) => value == null ? 'Requerido' : null,
            ),
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text(
              'Error al cargar negocios: $e',
              style: const TextStyle(color: AppColors.negative),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(widget.garden == null ? 'CREAR JARDÍN' : 'ACTUALIZAR'),
            ),
          ),
        ],
      ),
    );
  }
}
