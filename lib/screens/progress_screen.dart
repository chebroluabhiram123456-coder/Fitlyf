import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:fitflow/providers/workout_provider.dart';
import 'package:fitflow/widgets/gradient_background.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WorkoutProvider>(context);
    final theme = Theme.of(context).textTheme;
    final weightHistory = provider.weightHistory.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('Your Progress', style: theme.titleLarge),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Weight Tracking (kg)", style: theme.headlineSmall?.copyWith(color: Colors.white)),
              const SizedBox(height: 20),
              Container(
                height: 200,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: weightHistory.length < 2
                    ? const Center(child: Text("Not enough data to show a chart.", style: TextStyle(color: Colors.white)))
                    : LineChart(
                        LineChartData(
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
                              color: Colors.cyanAccent,
                              barWidth: 4,
                              isStrokeCapRound: true,
                              dotData: const FlDotData(show: true),
                              belowBarData: BarAreaData(
                                show: true,
                                color: Colors.cyanAccent.withOpacity(0.2),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
              const SizedBox(height: 30),
              Text("Workout History", style: theme.headlineSmall?.copyWith(color: Colors.white)),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: provider.workoutHistory.length,
                itemBuilder: (context, index) {
                  final session = provider.workoutHistory[index];
                  return Card(
                    color: Colors.black.withOpacity(0.3),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(session.muscleTarget, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      subtitle: Text('${session.exercises.length} exercises performed', style: const TextStyle(color: Colors.white70)),
                      trailing: Text(DateFormat('MMM d, y').format(session.date), style: const TextStyle(color: Colors.white70)),
                    ),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
