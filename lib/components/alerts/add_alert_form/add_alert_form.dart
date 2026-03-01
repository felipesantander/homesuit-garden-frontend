import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../../config/app_colors.dart';
import '../../../../models/alert.model.dart';
import '../../../../providers/alerts.provider.dart';
import '../smart_summary/smart_summary.widget.dart';
import '../machine_selector/machine_selector.widget.dart';
import '../criteria_section/criteria_section.widget.dart';
import '../contacts_section/contacts_section.widget.dart';

class AddAlertForm extends ConsumerStatefulWidget {
  final String? alertId;
  const AddAlertForm({super.key, this.alertId});

  @override
  ConsumerState<AddAlertForm> createState() => _AddAlertFormState();
}

class _AddAlertFormState extends ConsumerState<AddAlertForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _durationController;

  late String _selectedFrequency;
  late List<String> _selectedMachines;
  late List<AlertCriteria> _criteria;
  late List<AlertContact> _contacts;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Start with empty defaults
    _nameController = TextEditingController(text: '');
    _durationController = TextEditingController(text: '600');
    _selectedFrequency = '1_minutes';
    _selectedMachines = [];
    _criteria = [];
    _contacts = [AlertContact(name: '', phone: '')];

    final alertId = widget.alertId;
    if (alertId != null && alertId.isNotEmpty) {
      _isLoading = true;
      Future.microtask(() => _fetchFullAlertDetails(alertId));
    }
  }

  Future<void> _fetchFullAlertDetails(String id) async {
    try {
      final fullAlert = await ref.read(alertServiceProvider).getAlert(id);
      if (mounted) {
        setState(() {
          _nameController.text = fullAlert.name;
          _durationController.text = fullAlert.duration.toString();
          _selectedFrequency = fullAlert.dataFrequency;
          _selectedMachines = List<String>.from(fullAlert.machines);
          _criteria = List<AlertCriteria>.from(fullAlert.criteria);
          if (fullAlert.contacts.isNotEmpty) {
            _contacts = List<AlertContact>.from(fullAlert.contacts);
          } else {
            _contacts = [AlertContact(name: '', phone: '')];
          }
        });
      }
    } catch (e) {
      if (e is DioException) {
        print('DEBUG: DIO ERROR 404 for URI: ${e.requestOptions.uri}');
      }
      print('DEBUG: Error completo: $e');
      // Ignoramos el error, los campos mantienen los predeterminados de la lista
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate() &&
        _selectedMachines.isNotEmpty &&
        _criteria.isNotEmpty) {
      final newAlert = Alert(
        id: '', // Backend genera ID
        name: _nameController.text,
        machines: _selectedMachines,
        duration: int.parse(_durationController.text),
        dataFrequency: _selectedFrequency,
        contacts: _contacts.where((c) => c.phone.isNotEmpty).toList(),
        criteria: _criteria,
        isActive: true,
      );

      if (widget.alertId != null && widget.alertId!.isNotEmpty) {
        // Actualizar alerta existente
        ref
            .read(alertsProvider.notifier)
            .updateAlert(widget.alertId!, newAlert.toJson())
            .then((_) {
              if (!mounted) return;
              Navigator.of(context).pop();
            })
            .catchError((e) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error al actualizar alerta: $e')),
              );
            });
      } else {
        // Crear nueva alerta
        ref
            .read(alertsProvider.notifier)
            .createAlert(newAlert)
            .then((_) {
              if (!mounted) return;
              Navigator.of(context).pop();
            })
            .catchError((e) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error al crear alerta: $e')),
              );
            });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 300,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.alertId != null
                ? 'Editar Configuración de Alerta'
                : 'Configuración de Alerta',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            widget.alertId != null
                ? 'Modifica los criterios y contactos de esta alerta.'
                : 'Define los criterios y contactos para esta nueva alerta.',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          SmartSummaryWidget(
            selectedMachines: _selectedMachines,
            criteria: _criteria,
            duration: _durationController.text,
            contacts: _contacts,
          ),
          const SizedBox(height: 32),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nombre de la Alerta',
              hintText: 'Ej: Alerta Temp Elevada',
            ),
            validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
          ),
          const SizedBox(height: 24),
          MachineSelectorWidget(
            selectedMachines: _selectedMachines,
            onChanged: (List<String> v) =>
                setState(() => _selectedMachines = v),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _durationController,
                  decoration: const InputDecoration(
                    labelText: 'Duración (segundos)',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedFrequency,
                  decoration: const InputDecoration(
                    labelText: 'Frecuencia de Datos',
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: '1_minutes',
                      child: Text('1 Minuto'),
                    ),
                    DropdownMenuItem(
                      value: '5_minutes',
                      child: Text('5 Minutos'),
                    ),
                  ],
                  onChanged: (v) => setState(() => _selectedFrequency = v!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          CriteriaSectionWidget(
            criteria: _criteria,
            onChanged: (v) => setState(() => _criteria = v),
          ),
          const SizedBox(height: 24),
          ContactsSectionWidget(
            contacts: _contacts,
            onChanged: (v) => setState(() => _contacts = v),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                child: const Text('Guardar Alerta'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
