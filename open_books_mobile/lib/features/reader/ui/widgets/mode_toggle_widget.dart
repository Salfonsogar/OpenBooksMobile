import 'package:flutter/material.dart';
import '../../data/models/reader_mode.dart';

class ModeToggleWidget extends StatelessWidget {
  final ReaderMode currentMode;
  final ValueChanged<ReaderMode> onModeChanged;
  
  const ModeToggleWidget({
    super.key,
    required this.currentMode,
    required this.onModeChanged,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSegment(context, ReaderMode.reading, Icons.menu_book, 'Lectura'),
          _buildSegment(context, ReaderMode.audio, Icons.headphones, 'Audio'),
        ],
      ),
    );
  }
  
  Widget _buildSegment(BuildContext context, ReaderMode mode, IconData icon, String label) {
    final isSelected = currentMode == mode;
    return GestureDetector(
      onTap: () => onModeChanged(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: isSelected ? Theme.of(context).colorScheme.onPrimary : null),
            if (isSelected) ...[
              const SizedBox(width: 4),
              Text(label, style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              )),
            ],
          ],
        ),
      ),
    );
  }
}