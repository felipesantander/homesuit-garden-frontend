import 'package:flutter/material.dart';
import 'package:garden_homesuit/config/app_colors.dart';
import 'package:garden_homesuit/models/permission.model.dart';
import 'package:garden_homesuit/styles/input_styles.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(
          title: 'Endpoints Autorizados',
          icon: Icons.api_rounded,
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
          ),
          child: Column(
            children: [
              if (widget.endpoints.isNotEmpty) ...[
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.endpoints.length,
                  itemBuilder: (context, index) {
                    final ep = widget.endpoints[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppColors.background.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.border.withValues(alpha: 0.3),
                        ),
                      ),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            ep.method,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        title: Text(
                          ep.path,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        subtitle: ep.host.isNotEmpty
                            ? Text(
                                'Host: ${ep.host}',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              )
                            : null,
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.delete_outline_rounded,
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
                const Divider(color: AppColors.border, height: 32),
              ],
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: InputDecorator(
                      decoration: AppInputStyles.glass(labelText: 'Método'),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _method,
                          isExpanded: true,
                          isDense: true,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          dropdownColor: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          items: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE']
                              .map(
                                (m) =>
                                    DropdownMenuItem(value: m, child: Text(m)),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => _method = v!),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _pathController,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: AppInputStyles.glass(
                        labelText: 'Ruta (Ej. /api/...)',
                        prefixIcon: const Icon(Icons.link_rounded),
                      ),
                      onFieldSubmitted: (_) => _addEndpoint(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _hostController,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: AppInputStyles.glass(
                        labelText: 'Host (opcional)',
                        prefixIcon: const Icon(Icons.dns_rounded),
                      ),
                      onFieldSubmitted: (_) => _addEndpoint(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  IconButton.filled(
                    onPressed: _addEndpoint,
                    icon: const Icon(Icons.add_rounded, size: 28),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    tooltip: 'Agregar Endpoint',
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.border.withValues(alpha: 0.5),
                    AppColors.border.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
