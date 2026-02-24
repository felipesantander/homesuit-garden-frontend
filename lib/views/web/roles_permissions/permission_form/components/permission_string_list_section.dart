import 'package:flutter/material.dart';
import 'package:garden_homesuit/config/app_colors.dart';

class PermissionStringListSection extends StatefulWidget {
  final String title;
  final List<String> items;
  final IconData icon;
  final VoidCallback onUpdate;

  const PermissionStringListSection({
    super.key,
    required this.title,
    required this.items,
    required this.icon,
    required this.onUpdate,
  });

  @override
  State<PermissionStringListSection> createState() =>
      _PermissionStringListSectionState();
}

class _PermissionStringListSectionState
    extends State<PermissionStringListSection> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addItem() {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      widget.items.add(_controller.text.trim());
      _controller.clear();
    });
    widget.onUpdate();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(widget.icon, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (widget.items.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return Chip(
                    label: Text(item),
                    onDeleted: () {
                      setState(() => widget.items.removeAt(index));
                      widget.onUpdate();
                    },
                    deleteIconColor: AppColors.negative,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.05),
                    side: BorderSide(
                      color: AppColors.primary.withValues(alpha: 0.2),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText:
                          'Agregar ${widget.title} (UUID o Identificador)',
                      border: const OutlineInputBorder(),
                    ),
                    onFieldSubmitted: (_) => _addItem(),
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: _addItem,
                  icon: const Icon(
                    Icons.add_circle,
                    color: AppColors.primary,
                    size: 40,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
