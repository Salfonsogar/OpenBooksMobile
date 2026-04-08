import 'package:flutter/material.dart';

import 'reader_colors.dart';

class ReaderFooter extends StatelessWidget {
  final int currentIndex;
  final int totalChapters;
  final ReaderColors colors;
  final double bottomPadding;
  final ValueChanged<int> onPageSelected;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback? onToc;
  final VoidCallback? onSettings;

  const ReaderFooter({
    super.key,
    required this.currentIndex,
    required this.totalChapters,
    required this.colors,
    required this.bottomPadding,
    required this.onPageSelected,
    required this.onPrevious,
    required this.onNext,
    this.onToc,
    this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    if (totalChapters == 0) {
      return const SizedBox();
    }

    final progress = ((currentIndex + 1) / totalChapters * 100).toInt();

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        color: colors.header,
        padding: EdgeInsets.only(
          bottom: bottomPadding + 12,
          left: 16,
          right: 16,
          top: 12,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: onToc,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Icon(Icons.list, color: colors.icon, size: 28),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTapUp: (details) {
                      final width = MediaQuery.of(context).size.width - 100;
                      final tapPosition = details.localPosition.dx;
                      final percentage = tapPosition / width;
                      final targetPage = (percentage * totalChapters).round().clamp(0, totalChapters - 1);
                      onPageSelected(targetPage);
                    },
                    onHorizontalDragUpdate: (details) {
                      final width = MediaQuery.of(context).size.width - 100;
                      final position = (details.localPosition.dx / width).clamp(0.0, 1.0);
                      final targetPage = (position * (totalChapters - 1)).round();
                      onPageSelected(targetPage.clamp(0, totalChapters - 1));
                    },
                    onHorizontalDragEnd: (_) => onPageSelected(currentIndex),
                    child: Container(
                      height: 40,
                      color: Colors.transparent,
                      child: Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: (currentIndex + 1) / totalChapters,
                            backgroundColor: colors.text.withValues(alpha: 0.3),
                            valueColor: AlwaysStoppedAnimation<Color>(colors.text),
                            minHeight: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onSettings,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Icon(Icons.settings, color: colors.icon, size: 28),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$progress%',
                  style: TextStyle(color: colors.icon, fontSize: 12),
                ),
                const SizedBox(width: 16),
                Text(
                  '${currentIndex + 1}/$totalChapters',
                  style: TextStyle(color: colors.icon, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
