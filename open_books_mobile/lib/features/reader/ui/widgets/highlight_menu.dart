import 'package:flutter/material.dart';

import '../../../../shared/core/constants/app_constants.dart';

class HighlightMenu extends StatelessWidget {
  final Color backgroundColor;
  final Function(String color) onColorSelected;
  final VoidCallback onDismiss;

  const HighlightMenu({
    super.key,
    required this.backgroundColor,
    required this.onColorSelected,
    required this.onDismiss,
  });

  static const List<Map<String, dynamic>> _colors = [
    {'name': 'yellow', 'color': AppColors.highlightYellow},
    {'name': 'green', 'color': AppColors.highlightGreen},
    {'name': 'blue', 'color': AppColors.highlightBlue},
    {'name': 'pink', 'color': AppColors.highlightPink},
    {'name': 'orange', 'color': AppColors.highlightOrange},
  ];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onDismiss,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: _colors.map((colorData) {
            return GestureDetector(
              onTap: () => onColorSelected(colorData['name'] as String),
              child: Container(
                width: 26,
                height: 26,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: colorData['color'] as Color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
