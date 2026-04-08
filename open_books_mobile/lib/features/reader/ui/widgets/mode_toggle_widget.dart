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
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSegment(context, ReaderMode.reading, Icons.menu_book),
          _buildSegment(context, ReaderMode.audio, Icons.headphones),
        ],
      ),
    );
  }
  
  Widget _buildSegment(BuildContext context, ReaderMode mode, IconData icon) {
    final isSelected = currentMode == mode;
    return GestureDetector(
      onTap: () => onModeChanged(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          icon, 
          size: 20, 
          color: isSelected 
            ? Theme.of(context).colorScheme.onPrimary 
            : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}