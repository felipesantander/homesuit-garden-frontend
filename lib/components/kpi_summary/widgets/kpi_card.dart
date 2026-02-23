import 'package:flutter/material.dart';
import 'package:garden_homesuit/config/app_colors.dart';

class KpiCard extends StatefulWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isAnimate;

  const KpiCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.isAnimate = false,
  });

  @override
  State<KpiCard> createState() => _KpiCardState();
}

class _KpiCardState extends State<KpiCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    if (widget.isAnimate) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(KpiCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnimate && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isAnimate && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 160),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.color.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.color.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _IconIndicator(
            icon: widget.icon,
            color: widget.color,
            isAnimate: widget.isAnimate,
            animation: _controller,
          ),
          const SizedBox(width: 16),
          _ValueDisplay(label: widget.label, value: widget.value),
        ],
      ),
    );
  }
}

class _IconIndicator extends StatelessWidget {
  final IconData icon;
  final Color color;
  final bool isAnimate;
  final Animation<double> animation;

  const _IconIndicator({
    required this.icon,
    required this.color,
    required this.isAnimate,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(
              alpha: isAnimate ? 0.1 + (animation.value * 0.1) : 0.1,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              if (isAnimate)
                BoxShadow(
                  color: color.withValues(alpha: 0.2),
                  blurRadius: 4 + (animation.value * 8),
                  spreadRadius: animation.value * 2,
                ),
            ],
          ),
          child: Icon(icon, color: color, size: 20),
        );
      },
    );
  }
}

class _ValueDisplay extends StatelessWidget {
  final String label;
  final String value;

  const _ValueDisplay({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
