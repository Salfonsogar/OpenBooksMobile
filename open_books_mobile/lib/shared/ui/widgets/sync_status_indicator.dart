import 'package:flutter/material.dart';

class SyncStatusIndicator extends StatelessWidget {
  final int pendingCount;
  final VoidCallback? onTap;
  final bool isSyncing;

  const SyncStatusIndicator({
    super.key,
    required this.pendingCount,
    this.onTap,
    this.isSyncing = false,
  });

  @override
  Widget build(BuildContext context) {
    if (pendingCount == 0 && !isSyncing) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _getBackgroundColor(context),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSyncing)
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              )
            else
              Icon(
                _getIcon(),
                size: 14,
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            const SizedBox(width: 4),
            Text(
              isSyncing ? 'Sincronizando...' : pendingCount.toString(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSecondaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getBackgroundColor(BuildContext context) {
    if (isSyncing) {
      return Theme.of(context).colorScheme.secondaryContainer;
    }
    if (pendingCount > 0) {
      return Theme.of(context).colorScheme.errorContainer;
    }
    return Theme.of(context).colorScheme.surfaceContainerHighest;
  }

  IconData _getIcon() {
    if (pendingCount > 3) {
      return Icons.cloud_off;
    }
    return Icons.cloud_queue;
  }
}