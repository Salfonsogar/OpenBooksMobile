import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ReadingStatsBarChart extends StatelessWidget {
  final int pagesToday;
  final int pagesWeek;
  final int pagesMonth;
  final double height;

  const ReadingStatsBarChart({
    super.key,
    required this.pagesToday,
    required this.pagesWeek,
    required this.pagesMonth,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    final maxValue = [pagesToday, pagesWeek, pagesMonth].reduce((a, b) => a > b ? a : b);
    final maxY = maxValue > 0 ? (maxValue * 1.2).ceilToDouble() : 100.0;

    return SizedBox(
      height: height,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceEvenly,
          maxY: maxY,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final labels = ['Hoy', 'Esta semana', 'Este mes'];
                return BarTooltipItem(
                  '${labels[group.x.toInt()]}\n${rod.toY.toInt()} páginas',
                  TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
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
                  final labels = ['Hoy', 'Semana', 'Mes'];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      labels[value.toInt()],
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  );
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 45,
                interval: maxY / 4,
                getTitlesWidget: (value, meta) {
                  return Text(
                    _formatNumber(value.toInt()),
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
            horizontalInterval: maxY / 4,
          ),
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                  toY: pagesToday.toDouble(),
                  color: const Color(0xFF4CAF50),
                  width: 30,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
              ],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(
                  toY: pagesWeek.toDouble(),
                  color: const Color(0xFF2196F3),
                  width: 30,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
              ],
            ),
            BarChartGroupData(
              x: 2,
              barRods: [
                BarChartRodData(
                  toY: pagesMonth.toDouble(),
                  color: const Color(0xFFFF9800),
                  width: 30,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatNumber(int value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k';
    }
    return value.toString();
  }
}