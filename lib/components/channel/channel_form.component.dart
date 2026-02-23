import 'package:flutter/material.dart';
import 'package:garden_homesuit/config/app_colors.dart';
import 'package:garden_homesuit/models/channel.model.dart';
import 'package:garden_homesuit/providers/channels.provider.dart';
import 'package:garden_homesuit/providers/businesses.provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ChannelForm extends ConsumerStatefulWidget {
  final Channel? channel;
  final VoidCallback onSaved;

  const ChannelForm({super.key, this.channel, required this.onSaved});

  @override
  ConsumerState<ChannelForm> createState() => _ChannelFormState();
}

class _ChannelFormState extends ConsumerState<ChannelForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _unitController;
  String? _selectedBusiness;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.channel?.name ?? '');
    _unitController = TextEditingController(text: widget.channel?.unit ?? '');
    _selectedBusiness = widget.channel?.business;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (widget.channel == null) {
        await ref
            .read(channelsProvider.notifier)
            .createChannel(
              _nameController.text,
              unit: _unitController.text,
              businessId: _selectedBusiness,
            );
      } else {
        await ref
            .read(channelsProvider.notifier)
            .updateChannel(widget.channel!.idChannel, {
              'name': _nameController.text,
              'unit': _unitController.text,
              'business': _selectedBusiness,
            });
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
                widget.channel == null
                    ? Icons.add_rounded
                    : Icons.edit_note_rounded,
                color: AppColors.primary,
              ),
              const SizedBox(width: 12),
              Text(
                widget.channel == null ? 'Nuevo Canal' : 'Editar Canal',
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
            'Nombre del Canal',
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
              hintText: 'Ej: Canal de Temperatura',
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
            'Unidad de Medición',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _unitController,
            decoration: InputDecoration(
              hintText: 'Ej: °C, %, Lux',
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.straighten_rounded),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Negocio (Opcional)',
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
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('Ninguno'),
                ),
                ...businesses.map((business) {
                  return DropdownMenuItem(
                    value: business.idBusiness,
                    child: Text(business.name),
                  );
                }),
              ],
              onChanged: (value) => setState(() => _selectedBusiness = value),
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
                  : Text(widget.channel == null ? 'CREAR CANAL' : 'ACTUALIZAR'),
            ),
          ),
        ],
      ),
    );
  }
}
