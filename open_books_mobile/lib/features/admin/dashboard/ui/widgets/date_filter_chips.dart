import 'package:flutter/material.dart';

import '../../logic/cubit/admin_dashboard_state.dart';

class DateFilterChips extends StatelessWidget {
  final DateFilter currentFilter;
  final ValueChanged<DateFilter> onFilterChanged;
  final VoidCallback onCustomRange;

  const DateFilterChips({
    super.key,
    required this.currentFilter,
    required this.onFilterChanged,
    required this.onCustomRange,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildChip(context, DateFilter.hoy, 'Hoy'),
          const SizedBox(width: 8),
          _buildChip(context, DateFilter.semana, 'Semana'),
          const SizedBox(width: 8),
          _buildChip(context, DateFilter.mes, 'Mes'),
          const SizedBox(width: 8),
          _buildChip(
            context,
            DateFilter.personalizado,
            'Personalizado',
            icon: Icons.date_range,
            onTap: onCustomRange,
          ),
        ],
      ),
    );
  }

  Widget _buildChip(
    BuildContext context,
    DateFilter filter,
    String label, {
    IconData? icon,
    VoidCallback? onTap,
  }) {
    final isSelected = currentFilter == filter;
    final colorScheme = Theme.of(context).colorScheme;

    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16),
            const SizedBox(width: 4),
          ],
          Text(label),
        ],
      ),
      onSelected: (_) {
        if (onTap != null) {
          onTap();
        } else {
          onFilterChanged(filter);
        }
      },
      selectedColor: colorScheme.primaryContainer,
      checkmarkColor: colorScheme.onPrimaryContainer,
      labelStyle: TextStyle(
        color: isSelected
            ? colorScheme.onPrimaryContainer
            : colorScheme.onSurfaceVariant,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}

Future<DateTimeRange?> showCustomDateRangePicker(BuildContext context) async {
  final now = DateTime.now();
  return showDateRangePicker(
    context: context,
    firstDate: now.subtract(const Duration(days: 365)),
    lastDate: now,
    initialDateRange: DateTimeRange(
      start: now.subtract(const Duration(days: 30)),
      end: now,
    ),
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme,
        ),
        child: child!,
      );
    },
  );
}