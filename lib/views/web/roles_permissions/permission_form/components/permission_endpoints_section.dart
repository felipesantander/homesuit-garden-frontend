import 'package:flutter/material.dart';
import 'package:garden_homesuit/config/app_colors.dart';
import 'package:garden_homesuit/models/permission.model.dart';

class PermissionEndpointsSection extends StatefulWidget {
  final List<PermissionEndpoint> endpoints;
  final VoidCallback onUpdate;

  const PermissionEndpointsSection({
    super.key,
    required this.endpoints,
    required this.onUpdate,
  });

  @override
  State<PermissionEndpointsSection> createState() =>
      _PermissionEndpointsSectionState();
}

class _PermissionEndpointsSectionState
    extends State<PermissionEndpointsSection> {
  final _pathController = TextEditingController();
  final _hostController = TextEditingController();
  String _method = 'GET';

  @override
  void dispose() {
    _pathController.dispose();
    _hostController.dispose();
    super.dispose();
  }

  void _addEndpoint() {
    if (_pathController.text.trim().isEmpty) return;

    setState(() {
      widget.endpoints.add(
        PermissionEndpoint(
          path: _pathController.text.trim(),
          host: _hostController.text.trim(),
          method: _method,
        ),
      );
      _pathController.clear();
      _hostController.clear();
      _method = 'GET';
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
            const Text(
              'Endpoints Autorizados',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (widget.endpoints.isNotEmpty) ...[
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.endpoints.length,
                itemBuilder: (context, index) {
                  final ep = widget.endpoints[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      dense: true,
                      leading: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          ep.method,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      title: Text(ep.path),
                      subtitle: ep.host.isNotEmpty
                          ? Text('Host: ${ep.host}')
                          : null,
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: AppColors.negative,
                        ),
                        onPressed: () {
                          setState(() => widget.endpoints.removeAt(index));
                          widget.onUpdate();
                        },
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Método',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _method,
                        isExpanded: true,
                        isDense: true,
                        items: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE']
                            .map(
                              (m) => DropdownMenuItem(value: m, child: Text(m)),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _method = v!),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _pathController,
                    decoration: const InputDecoration(
                      labelText: 'Path (Ej. /api/...)',
                      border: OutlineInputBorder(),
                    ),
                    onFieldSubmitted: (_) => _addEndpoint(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _hostController,
                    decoration: const InputDecoration(
                      labelText: 'Host (opcional)',
                      border: OutlineInputBorder(),
                    ),
                    onFieldSubmitted: (_) => _addEndpoint(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _addEndpoint,
                  icon: const Icon(
                    Icons.add_circle,
                    color: AppColors.primary,
                    size: 40,
                  ),
                  tooltip: 'Agregar Endpoint',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
