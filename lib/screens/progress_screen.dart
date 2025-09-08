import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitlyf/providers/workout_provider.dart';
import 'package:fitlyf/widgets/frosted_glass_card.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // This Container provides the purple gradient background to match the HomeScreen
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
          title: const Text('Your Progress', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Consumer<WorkoutProvider>(
          builder: (context, workoutProvider, child) {
            // *** FIX 1: Correctly get and sort the weight history ***
            // weightHistory is a List<WeightLog>, not a Map.
            final weightHistory = workoutProvider.weightHistory;
            weightHistory.sort((a, b) => a.date.compareTo(b.date));
            
            // *** FIX 2: Calculate overall workout stats from your history ***
            // This reflects your long-term progress, not just one day.
            final completedWorkouts = workoutProvider.workoutLog
                .where((log) => log.status == WorkoutStatus.Completed)
                .length;
            final totalLoggedWorkouts = workoutProvider.workoutLog.length;

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Weight Analytics",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    // Your original weight chart card, now with corrected data
                    _buildWeightChartCard(context, weightHistory),
                    const SizedBox(height: 30),
                    const Text(
                      "Workout Stats",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    // Your original stats card, now with corrected data
                    _buildStatsCard(context, completedWorkouts, totalLoggedWorkouts),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Your original _buildWeightChartCard, with the input type changed to List<WeightLog>
  Widget _buildWeightChartCard(BuildContext context, List<WeightLog> weightHistory) {
    return FrostedGlassCard(
      child: AspectRatio(
        aspectRatio: 1.7,
        child: weightHistory.length < 2 
            ? const Center(
                child: Text(
                  "Log more than one weight entry to see your chart!",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              )
            : LineChart(
                _buildChartData(context, weightHistory),
                duration: const Duration(milliseconds: 400),
              ),
      ),
    );
  }

  // Your original _buildStatsCard, with variable names updated for clarity
  Widget _buildStatsCard(BuildContext context, int completed, int total) {
    double percentage = total > 0 ? (completed / total) * 100 : 0;

    return FrostedGlassCard(
      padding: const EdgeInsets.all(25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text(
                "$completed / $total",
                style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const Text("Workouts Done", style: TextStyle(color: Colors.white70)),
            ],
          ),
          Column(
            children: [
              Text(
                "${percentage.toStringAsFixed(0)}%",
                style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const Text("Completion", style: TextStyle(color: Colors.white70)),
            ],
          ),
        ],
      ),
    );
  }

  // Your original _buildChartData, with logic updated to read from a List<WeightLog>
  LineChartData _buildChartData(BuildContext context, List<WeightLog> weightHistory) {
    List<FlSpot> spots = weightHistory.asMap().entries.map((entry) {
      // Use the list index for the x-axis and the log's weight for the y-axis
      return FlSpot(entry.key.toDouble(), entry.value.weight);
    }).toList();

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        getDrawingHorizontalLine: (value) => const FlLine(color: Colors.white24, strokeWidth: 0.8),
        getDrawingVerticalLine: (value) => const FlLine(color: Colors.white24, strokeWidth: 0.8),
      ),
      titlesData: FlTitlesData(
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 35, interval: 2)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: (spots.length / 4).ceil().toDouble(), // Show around 4 labels
            getTitlesWidget: (value, meta) {
              int index = value.toInt();
              if (index >= 0 && index < weightHistory.length) {
                // Correctly get the date from the WeightLog object
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 8.0,
                  child: Text(DateFormat('d MMM').format(weightHistory[index].date), style: const TextStyle(color: Colors.white70, fontSize: 12)),
                );
              }
              return const Text('');
            },
          ),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: true, border: Border.all(color: Colors.white24)),
      minX: 0,
      maxX: (spots.length - 1).toDouble(),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: Theme.of(context).colorScheme.secondary, // Use a nice theme color
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
          ),
        ),
      ],
    );
  }
}
