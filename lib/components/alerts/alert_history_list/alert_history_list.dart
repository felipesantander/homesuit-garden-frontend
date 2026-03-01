import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../config/app_colors.dart';
import '../../../../providers/alerts.provider.dart';
import 'package:intl/intl.dart';

class AlertHistoryList extends ConsumerWidget {
  const AlertHistoryList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(alertHistoryProvider);

    return historyAsync.when(
      data: (history) {
        if (history.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history_rounded,
                  size: 64,
                  color: AppColors.textSecondary,
                ),
                SizedBox(height: 16),
                Text(
                  'No hay historial de alertas',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(AppColors.background),
              columns: const [
                DataColumn(label: Text('Alerta')),
                DataColumn(label: Text('Máquina')),
                DataColumn(label: Text('Fecha y Hora')),
                DataColumn(label: Text('Detalles')),
              ],
              rows: history.map((event) {
                return DataRow(
                  cells: [
                    DataCell(
                      Text(
                        event.alertName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    DataCell(Text(event.machineSerial)),
                    DataCell(
                      Text(
                        DateFormat(
                          'dd/MM/yyyy HH:mm:ss',
                        ).format(event.triggeredAt),
                      ),
                    ),
                    DataCell(
                      IconButton(
                        icon: const Icon(
                          Icons.info_outline_rounded,
                          color: AppColors.primary,
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Detalles de Alerta'),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              content: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Criterios de Alerta:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    if (event.details.isEmpty)
                                      const Text('No hay detalles disponibles.')
                                    else
                                      ...event.details.map((detail) {
                                        if (detail is! Map)
                                          return const SizedBox.shrink();
                                        final channel =
                                            detail['channel'] ?? 'Desconocido';
                                        final condition =
                                            detail['condition'] ?? '';
                                        final threshold =
                                            detail['threshold']?.toString() ??
                                            '';
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 4.0,
                                          ),
                                          child: Text(
                                            '• $channel $condition $threshold',
                                            style: const TextStyle(
                                              fontSize: 15,
                                            ),
                                          ),
                                        );
                                      }),
                                    const SizedBox(height: 12),
                                    const Divider(),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'Contactos Notificados:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    if (event.contactsNotified.isEmpty)
                                      const Text('Nadie fue notificado.')
                                    else
                                      ...event.contactsNotified.map((contact) {
                                        if (contact is! Map)
                                          return const SizedBox.shrink();
                                        final name =
                                            contact['name'] ?? 'Desconocido';
                                        final phone = contact['phone'] ?? '';
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 4.0,
                                          ),
                                          child: Text(
                                            '• $name ($phone)',
                                            style: const TextStyle(
                                              fontSize: 15,
                                            ),
                                          ),
                                        );
                                      }),
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cerrar'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }
}
