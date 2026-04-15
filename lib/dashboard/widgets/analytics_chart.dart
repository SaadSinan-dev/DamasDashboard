import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:damas_dashboard/core/app_colors.dart';

class AnalyticsChartSection extends StatelessWidget {
  const AnalyticsChartSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: SizedBox(
        height: 300,
        child: LineChart(_chartData()),
      ),
    );
  }

  LineChartData _chartData() {
    return LineChartData(
      gridData: const FlGridData(show: true),
      titlesData: const FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: const [
            FlSpot(0, 30),
            FlSpot(2, 50),
            FlSpot(4, 45),
            FlSpot(6, 75),
            FlSpot(8, 60),
            FlSpot(10, 90),
          ],
          isCurved: true,
          color: AppColors.primaryDark,
          barWidth: 3,
          dotData: const FlDotData(show: false),
        ),
      ],
    );
  }
}