import 'package:flutter/material.dart';
import 'package:garden_homesuit/config/app_colors.dart';

class MachineStatusBadge extends StatefulWidget {
  final bool isOnline;
  final String relativeTime;
  final String? fullTimestamp;

  const MachineStatusBadge({
    super.key,
    required this.isOnline,
    required this.relativeTime,
    this.fullTimestamp,
  });

  @override
  State<MachineStatusBadge> createState() => _MachineStatusBadgeState();
}

class _MachineStatusBadgeState extends State<MachineStatusBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatRelativeTime(String timeStr) {
    if (timeStr == 'No info' ||
        timeStr == 'Nunca' ||
        timeStr.startsWith('Hace ')) {
      return timeStr;
    }
    try {
      final lastCapture = DateTime.parse(timeStr);
      final difference = DateTime.now().toUtc().difference(lastCapture);
      if (difference.inSeconds < 60) return 'Hace instantes';
      if (difference.inMinutes < 60) return 'Hace ${difference.inMinutes}m';
      if (difference.inHours < 24) return 'Hace ${difference.inHours}h';
      // Format as DD/MM/YYYY HH:mm instead of displaying the raw string
      return '${lastCapture.toLocal().day.toString().padLeft(2, '0')}/${lastCapture.toLocal().month.toString().padLeft(2, '0')} ${lastCapture.toLocal().hour.toString().padLeft(2, '0')}:${lastCapture.toLocal().minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return timeStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = widget.isOnline ? AppColors.water : AppColors.negative;
    final displayTime = _formatRelativeTime(widget.relativeTime);

    return Tooltip(
      message: widget.fullTimestamp ?? 'Sin fecha',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: statusColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: statusColor.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                if (widget.isOnline)
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Container(
                        width: 12 + (_controller.value * 12),
                        height: 12 + (_controller.value * 12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: statusColor.withValues(
                            alpha: 0.2 * (1 - _controller.value),
                          ),
                        ),
                      );
                    },
                  ),
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          if (widget.isOnline)
                            BoxShadow(
                              color: statusColor.withValues(alpha: 0.6),
                              blurRadius: 4 + (_controller.value * 4),
                              spreadRadius: _controller.value * 1,
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(width: 8),
            Text(
              widget.isOnline ? 'ONLINE' : 'OFFLINE',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: statusColor,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              width: 1,
              height: 10,
              color: statusColor.withValues(alpha: 0.2),
            ),
            const SizedBox(width: 6),
            Text(
              displayTime,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: statusColor.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
