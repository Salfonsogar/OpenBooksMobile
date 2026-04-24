import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../data/models/admin_stats.dart';

class TopLibrosBarChart extends StatelessWidget {
  final List<LibroPopularData> topLibros;
  final double height;

  const TopLibrosBarChart({
    super.key,
    required this.topLibros,
    this.height = 250,
  });

  @override
  Widget build(BuildContext context) {
    if (topLibros.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(
          child: Text('No hay datos de libros leídos'),
        ),
      );
    }

    final maxPages = topLibros.map((e) => e.paginasLeidas).reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: height,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxPages.toDouble() * 1.2,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final libro = topLibros[group.x.toInt()];
                return BarTooltipItem(
                  '${libro.titulo}\n${libro.paginasLeidas} páginas',
                  TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= topLibros.length) {
                    return const SizedBox.shrink();
                  }
                  final titulo = topLibros[value.toInt()].titulo;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      titulo.length > 10 ? '${titulo.substring(0, 10)}...' : titulo,
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                },
                reservedSize: 40,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxPages > 0 ? maxPages / 5 : 1,
          ),
          barGroups: topLibros.asMap().entries.map((entry) {
            final index = entry.key;
            final libro = entry.value;
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: libro.paginasLeidas.toDouble(),
                  color: _getBarColor(index),
                  width: 20,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Color _getBarColor(int index) {
    const colors = [
      Color(0xFF2196F3),
      Color(0xFF4CAF50),
      Color(0xFFFF9800),
      Color(0xFF9C27B0),
      Color(0xFFE91E63),
      Color(0xFF00BCD4),
      Color(0xFF795548),
      Color(0xFF607D8B),
      Color(0xFF3F51B5),
      Color(0xFF009688),
    ];
    return colors[index % colors.length];
  }
}