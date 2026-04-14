import 'package:flutter/material.dart';
import '../../data/models/reader_mode.dart';
import 'reader_colors.dart';

class ModeToggleWidget extends StatelessWidget {
  final ReaderMode currentMode;
  final ValueChanged<ReaderMode> onModeChanged;
  final ReaderColors colors;
  
  const ModeToggleWidget({
    super.key,
    required this.currentMode,
    required this.onModeChanged,
    required this.colors,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
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
          color: isSelected ? colors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon( 
          size: 20, 
          icon,
          color: isSelected 
            ? colors.background 
            : colors.text.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}