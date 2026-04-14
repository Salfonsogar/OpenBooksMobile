import 'package:flutter/material.dart';

import '../../data/models/reader_mode.dart';
import 'reader_colors.dart';
import 'mode_toggle_widget.dart';

class ReaderHeader extends StatelessWidget {
  final String title;
  final ReaderColors colors;
  final double topPadding;
  final VoidCallback onBack;
  final VoidCallback onSearch;
  final VoidCallback onSettings;
  final ReaderMode currentMode;
  final ValueChanged<ReaderMode>? onModeChanged;

  const ReaderHeader({
    super.key,
    required this.title,
    required this.colors,
    required this.topPadding,
    required this.onBack,
    required this.onSearch,
    required this.onSettings,
    this.currentMode = ReaderMode.reading,
    this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        color: colors.header,
        padding: EdgeInsets.only(
          top: topPadding + 4,
          left: 12,
          right: 12,
          bottom: 12,
        ),
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back, color: colors.icon, size: 28),
              onPressed: onBack,
            ),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: colors.icon,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (onModeChanged != null)
              ModeToggleWidget(
                currentMode: currentMode,
                onModeChanged: onModeChanged!,
                colors: colors,
              ),
            IconButton(
              icon: Icon(
                currentMode == ReaderMode.audio ? Icons.settings : Icons.search,
                color: colors.icon,
                size: 28,
              ),
              onPressed: currentMode == ReaderMode.audio ? onSettings : onSearch,
            ),
          ],
        ),
      ),
    );
  }
}
