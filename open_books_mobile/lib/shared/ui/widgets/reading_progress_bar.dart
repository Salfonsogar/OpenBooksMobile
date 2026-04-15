import 'package:flutter/material.dart';

class ReadingProgressBar extends StatelessWidget {
  final double progreso;
  final double height;
  final bool showPercentage;
  final bool showLabel;
  final Color? backgroundColor;
  final Color? progressColor;
  final String? label;

  const ReadingProgressBar({
    super.key,
    required this.progreso,
    this.height = 8,
    this.showPercentage = true,
    this.showLabel = false,
    this.backgroundColor,
    this.progressColor,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final clampedProgreso = progreso.clamp(0.0, 100.0);
    final effectiveProgressColor = progressColor ?? _getProgressColor(context, clampedProgreso);
    final effectiveBackgroundColor = backgroundColor ?? Theme.of(context).colorScheme.surfaceContainerHighest;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLabel && label != null) ...[
          Text(
            label!,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
        ],
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(height / 2),
                child: LinearProgressIndicator(
                  value: clampedProgreso / 100,
                  backgroundColor: effectiveBackgroundColor,
                  valueColor: AlwaysStoppedAnimation<Color>(effectiveProgressColor),
                  minHeight: height,
                ),
              ),
            ),
            if (showPercentage) ...[
              const SizedBox(width: 8),
              Text(
                '${clampedProgreso.toInt()}%',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: effectiveProgressColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Color _getProgressColor(BuildContext context, double progreso) {
    if (progreso >= 100) {
      return Colors.green;
    } else if (progreso >= 50) {
      return Theme.of(context).colorScheme.primary;
    } else if (progreso >= 25) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}