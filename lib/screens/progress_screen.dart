import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:fitlyf/providers/workout_provider.dart';
import 'package:fitlyf/widgets/frosted_glass_card.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Use a Consumer to get the latest data
    return Consumer<WorkoutProvider>(
      builder: (context, provider, child) {
        final weightHistory = provider.weightHistory.entries.toList()
          ..sort((a, b) => a.key.compareTo(b.key));
        
        final workoutCount = provider.masterExerciseList.length;

        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4A148C), Color(0xFF2D1458), Color(0xFF1A0E38)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: const Text('Your Analytics'),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Weight Tracking (kg)", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  FrostedGlassCard(
                    child: SizedBox(
                      height: 200,
                      child: weightHistory.length < 2
                          ? const Center(child: Text("Log your weight for a few days to see a chart.", style: TextStyle(color: Colors.white70)))
                          : LineChart(
                              _buildChartData(weightHistory),
                            ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text("Workout Progress", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  FrostedGlassCard(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total Exercises Created:", style: TextStyle(fontSize: 16)),
                        Text("$workoutCount", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  LineChartData _buildChartData(List<MapEntry<DateTime, double>> weightHistory) {
    return LineChartData(
      gridData: FlGridData(show: false),
      titlesData: FlTitlesData(
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: (value, meta) {
              if (value.toInt() < weightHistory.length) {
                final date = weightHistory[value.toInt()].key;
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(DateFormat('d MMM').format(date), style: const TextStyle(color: Colors.white70, fontSize: 10)),
                );
              }
              return Container();
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: [
            for (int i = 0; i < weightHistory.length; i++)
              FlSpot(i.toDouble(), weightHistory[i].value),
          ],
          isCurved: true,
          color: Colors.purple.shade200,
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: true),
          belowBarData: BarAreaData(
            show: true,
            color: Colors.purple.shade200.withOpacity(0.2),
          ),
        ),
      ],
    );
  }
}
