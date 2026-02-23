import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:garden_homesuit/components/common/action_button.component.dart';
import 'package:garden_homesuit/config/app_colors.dart';
import 'package:garden_homesuit/models/business.model.dart';
import 'package:garden_homesuit/models/channel.model.dart';
import 'package:garden_homesuit/providers/businesses.provider.dart';
import 'package:garden_homesuit/providers/channels.provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ChannelCard extends ConsumerStatefulWidget {
  final Channel channel;
  final VoidCallback onEdit;

  const ChannelCard({super.key, required this.channel, required this.onEdit});

  @override
  ConsumerState<ChannelCard> createState() => _ChannelCardState();
}

class _ChannelCardState extends ConsumerState<ChannelCard> {
  bool _isHovered = false;

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Canal'),
        content: Text(
          '¿Estás seguro que deseas eliminar el canal "${widget.channel.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCELAR'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await ref
                  .read(channelsProvider.notifier)
                  .deleteChannel(widget.channel.idChannel);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.negative),
            child: const Text('ELIMINAR'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _isHovered ? -4 : 0, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : AppColors.shadow.withValues(alpha: 0.1),
              blurRadius: _isHovered ? 20 : 10,
              offset: Offset(0, _isHovered ? 12 : 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _isHovered
                      ? AppColors.primary.withValues(alpha: 0.3)
                      : AppColors.border.withValues(alpha: 0.5),
                  width: 1.5,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.surface.withValues(alpha: 0.8),
                    AppColors.surface.withValues(alpha: 0.4),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primarySoft,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.sensors_rounded,
                              color: AppColors.primary,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Canal',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          ActionButton(
                            icon: Icons.edit_outlined,
                            onTap: widget.onEdit,
                            color: AppColors.primary,
                            tooltip: 'Editar',
                          ),
                          const SizedBox(width: 8),
                          ActionButton(
                            icon: Icons.delete_outline_rounded,
                            onTap: _showDeleteConfirmation,
                            color: AppColors.negative,
                            tooltip: 'Eliminar',
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'NOMBRE DEL CANAL',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textMuted,
                          letterSpacing: 1.2,
                        ),
                      ),
                      if (widget.channel.unit.isNotEmpty)
                        const Text(
                          'UNIDAD DE MEDICIÓN',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textMuted,
                            letterSpacing: 1.2,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.channel.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (widget.channel.unit.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondarySoft,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            widget.channel.unit,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const Spacer(),
                  const Text(
                    'NEGOCIO ASOCIADO',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMuted,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.business_center_outlined,
                        size: 14,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 8),
                      Consumer(
                        builder: (context, ref, child) {
                          final businessesAsync = ref.watch(businessesProvider);
                          return businessesAsync.when(
                            data: (businesses) {
                              final business = businesses.firstWhere(
                                (b) => b.idBusiness == widget.channel.business,
                                orElse: () => Business(
                                  idBusiness: '',
                                  name:
                                      widget.channel.business ?? 'Sin negocio',
                                ),
                              );
                              return Text(
                                business.name,
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 12,
                                  color: widget.channel.business != null
                                      ? AppColors.primary
                                      : AppColors.textMuted,
                                  fontWeight: widget.channel.business != null
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              );
                            },
                            loading: () => const Text(
                              '...',
                              style: TextStyle(fontSize: 12),
                            ),
                            error: (err, stack) => Text(
                              widget.channel.business ?? 'Sin negocio',
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
