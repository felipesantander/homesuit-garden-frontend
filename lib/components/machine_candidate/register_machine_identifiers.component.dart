import 'package:flutter/material.dart';
import 'package:garden_homesuit/config/app_colors.dart';
import 'package:garden_homesuit/models/business.model.dart';
import 'package:garden_homesuit/models/garden.model.dart';

class RegisterMachineIdentifiers extends StatelessWidget {
  final TextEditingController nameController;
  final String serial;
  final String? selectedGarden;
  final List<Garden> gardens;
  final List<Business> businesses;
  final ValueChanged<String?> onGardenChanged;

  const RegisterMachineIdentifiers({
    super.key,
    required this.nameController,
    required this.serial,
    required this.selectedGarden,
    required this.gardens,
    required this.businesses,
    required this.onGardenChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        TextFormField(
          controller: nameController,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            labelText: 'Identificador del Nodo',
            hintText: 'Ej: NODO_INVERNADERO_01',
            prefixIcon: const Icon(
              Icons.settings_input_component_rounded,
              color: AppColors.primary,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.border, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.border, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            labelStyle: const TextStyle(color: AppColors.textSecondary),
            floatingLabelStyle: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          validator: (value) =>
              value == null || value.isEmpty ? 'Falta identificador' : null,
        ),
        const SizedBox(height: 20),
        TextFormField(
          initialValue: serial,
          readOnly: true,
          style: const TextStyle(fontFamily: 'Fira Code', fontSize: 14),
          decoration: InputDecoration(
            labelText: 'Número de Serie',
            prefixIcon: const Icon(Icons.qr_code_scanner),
            filled: true,
            fillColor: AppColors.background.withValues(alpha: 0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Asignación de Jardín',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String?>(
          initialValue: selectedGarden,
          decoration: InputDecoration(
            labelText: 'Jardín de Operación',
            prefixIcon: const Icon(
              Icons.yard_outlined,
              color: AppColors.primary,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.border, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.border, width: 1),
            ),
          ),
          items: [
            ...gardens.map((g) {
              final business = businesses.firstWhere(
                (b) => b.idBusiness == g.business,
                orElse: () => Business(idBusiness: '', name: 'Desconocido'),
              );
              return DropdownMenuItem<String?>(
                value: g.idGarden,
                child: Text('${g.name} (${business.name})'),
              );
            }),
          ],
          onChanged: onGardenChanged,
          validator: (value) => value == null ? 'Seleccione un jardín' : null,
        ),
      ],
    );
  }
}
