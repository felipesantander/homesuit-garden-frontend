import 'package:flutter/material.dart';
import '../../../../config/app_colors.dart';
import '../../../../models/alert.model.dart';

class ContactsSectionWidget extends StatelessWidget {
  final List<AlertContact> contacts;
  final ValueChanged<List<AlertContact>> onChanged;

  const ContactsSectionWidget({
    super.key,
    required this.contacts,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Contactos de Notificación',
          Icons.contact_mail_rounded,
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              ...contacts.asMap().entries.map((entry) {
                final idx = entry.key;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: contacts[idx].name,
                          decoration: const InputDecoration(
                            labelText: 'Nombre',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                            ),
                          ),
                          onChanged: (v) {
                            final newList = List<AlertContact>.from(contacts);
                            newList[idx] = AlertContact(
                              name: v,
                              phone: contacts[idx].phone,
                            );
                            onChanged(newList);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          initialValue: contacts[idx].phone,
                          decoration: const InputDecoration(
                            labelText: 'Teléfono',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                            ),
                          ),
                          keyboardType: TextInputType.phone,
                          onChanged: (v) {
                            final newList = List<AlertContact>.from(contacts);
                            newList[idx] = AlertContact(
                              name: contacts[idx].name,
                              phone: v,
                            );
                            onChanged(newList);
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.redAccent,
                        ),
                        onPressed: () {
                          final newList = List<AlertContact>.from(contacts)
                            ..removeAt(idx);
                          onChanged(newList);
                        },
                      ),
                    ],
                  ),
                );
              }),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () {
                    final newList = List<AlertContact>.from(contacts);
                    newList.add(AlertContact(name: '', phone: ''));
                    onChanged(newList);
                  },
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Agregar Contacto'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 32, bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
