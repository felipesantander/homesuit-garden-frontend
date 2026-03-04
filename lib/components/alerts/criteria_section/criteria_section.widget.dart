import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../config/app_colors.dart';
import '../../../../models/alert.model.dart';
import '../../../../models/channel.model.dart';
import '../../../../providers/channels.provider.dart';

class CriteriaSectionWidget extends ConsumerWidget {
  final List<AlertCriteria> criteria;
  final ValueChanged<List<AlertCriteria>> onChanged;

  const CriteriaSectionWidget({
    super.key,
    required this.criteria,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final channelsAsync = ref.watch(channelsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Criterios de Activación', Icons.rule),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              ...criteria.asMap().entries.map((entry) {
                final idx = entry.key;
                final c = entry.value;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (idx > 0)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: DropdownButton<String>(
                                value: c.logicalOperator ?? 'AND',
                                underline: const SizedBox(),
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                                icon: const Icon(
                                  Icons.arrow_drop_down,
                                  color: AppColors.primary,
                                ),
                                items: ['AND', 'OR']
                                    .map(
                                      (op) => DropdownMenuItem(
                                        value: op,
                                        child: Text(op),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) {
                                  final newList = List<AlertCriteria>.from(
                                    criteria,
                                  );
                                  newList[idx] = AlertCriteria(
                                    channel: c.channel,
                                    condition: c.condition,
                                    threshold: c.threshold,
                                    logicalOperator: v,
                                    order: idx,
                                  );
                                  onChanged(newList);
                                },
                              ),
                            ),
                            const Expanded(child: Divider(indent: 8)),
                          ],
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: channelsAsync.when<Widget>(
                              data: (List<Channel> channels) {
                                return DropdownButtonFormField<String>(
                                  initialValue: c.channel.isEmpty
                                      ? null
                                      : c.channel,
                                  decoration: const InputDecoration(
                                    labelText: 'Canal',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                  ),
                                  isExpanded: true,
                                  items: channels
                                      .map(
                                        (Channel ch) => DropdownMenuItem(
                                          value: ch.idChannel,
                                          child: Text(ch.name),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (v) {
                                    final newList = List<AlertCriteria>.from(
                                      criteria,
                                    );
                                    newList[idx] = AlertCriteria(
                                      channel: v!,
                                      condition: c.condition,
                                      threshold: c.threshold,
                                      logicalOperator: c.logicalOperator,
                                      order: idx,
                                    );
                                    onChanged(newList);
                                  },
                                );
                              },
                              loading: () => const SizedBox(),
                              error: (Object e, StackTrace s) =>
                                  const Text('Error'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 1,
                            child: DropdownButtonFormField<String>(
                              initialValue: c.condition,
                              decoration: const InputDecoration(
                                labelText: 'Op.',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                              ),
                              items: ['>', '<', '==', '>=', '<=']
                                  .map(
                                    (String o) => DropdownMenuItem(
                                      value: o,
                                      child: Text(o),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) {
                                final newList = List<AlertCriteria>.from(
                                  criteria,
                                );
                                newList[idx] = AlertCriteria(
                                  channel: c.channel,
                                  condition: v!,
                                  threshold: c.threshold,
                                  logicalOperator: c.logicalOperator,
                                  order: idx,
                                );
                                onChanged(newList);
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              initialValue: c.threshold.toString(),
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Umbral',
                                border: const OutlineInputBorder(),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                suffixText: channelsAsync.when(
                                  data: (List<Channel> channels) {
                                    final ch = channels.where(
                                      (Channel ch) => ch.idChannel == c.channel,
                                    );
                                    return ch.isNotEmpty ? ch.first.unit : '';
                                  },
                                  loading: () => '',
                                  error: (Object e, StackTrace s) => '',
                                ),
                              ),
                              onChanged: (v) {
                                final newList = List<AlertCriteria>.from(
                                  criteria,
                                );
                                newList[idx] = AlertCriteria(
                                  channel: c.channel,
                                  condition: c.condition,
                                  threshold: double.tryParse(v) ?? 0.0,
                                  logicalOperator: c.logicalOperator,
                                  order: idx,
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
                              final newList = List<AlertCriteria>.from(criteria)
                                ..removeAt(idx);
                              // Re-assign orders after deletion
                              onChanged(
                                newList.asMap().entries.map((e) {
                                  final i = e.key;
                                  final oldVal = e.value;
                                  return AlertCriteria(
                                    channel: oldVal.channel,
                                    condition: oldVal.condition,
                                    threshold: oldVal.threshold,
                                    logicalOperator: i == 0
                                        ? null
                                        : oldVal.logicalOperator ?? 'AND',
                                    order: i,
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () {
                    final newList = List<AlertCriteria>.from(criteria);
                    newList.add(
                      AlertCriteria(
                        channel: '',
                        condition: '>',
                        threshold: 0.0,
                        logicalOperator: newList.isEmpty ? null : 'AND',
                        order: newList.length,
                      ),
                    );
                    onChanged(newList);
                  },
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Agregar Criterio'),
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
