import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class StatusIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const StatusIcon({super.key, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      width: 72,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 40),
    ).animate().scale(
          duration: 350.ms,
          curve: Curves.easeOutBack,
          begin: const Offset(0.5, 0.5),
        );
  }
}

class SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const SummaryRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          Text(value, style: theme.textTheme.titleMedium),
        ],
      ),
    );
  }
}
