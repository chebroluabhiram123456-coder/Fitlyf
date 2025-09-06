import 'package.flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitlyf/providers/workout_provider.dart';
import 'package:fitlyf/widgets/frosted_glass_card.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutProvider>(
      builder: (context, workoutProvider, child) {
        final weightHistory = workoutProvider.weightHistory.entries.toList();
        // Sort the history by date to ensure the chart is correct
        weightHistory.sort((a, b) => a.key.compareTo(b.key));
        
        // Calculate workout stats
        final completedExercises = workoutProvider.allExercises.where((ex) => ex.isCompleted).length;
        final totalExercises = workoutProvider.allExercises.length;

        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('Your Progress', style: TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: SingleChildScrollView(
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
                  _buildWeightChartCard(context, weightHistory),
                  const SizedBox(height: 30),
                  const Text(
                    "Workout Stats",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  _buildStatsCard(context, completedExercises, totalExercises),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeightChartCard(BuildContext context, List<MapEntry<DateTime, double>> weightHistory) {
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
              ),
      ),
    );
  }

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
              const Text("Exercises Done", style: TextStyle(color: Colors.white70)),
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

  LineChartData _buildChartData(BuildContext context, List<MapEntry<DateTime, double>> weightHistory) {
    List<FlSpot> spots = weightHistory.asMap().entries.map((entry) {
      // Use index for x-axis and weight for y-axis
      return FlSpot(entry.key.toDouble(), entry.value.value);
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
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 8.0,
                  child: Text(DateFormat('d MMM').format(weightHistory[index].key)),
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
          color: Theme.of(context).primaryColor,
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: Theme.of(context).primaryColor.withOpacity(0.3),
          ),
        ),
      ],
    );
  }
}
