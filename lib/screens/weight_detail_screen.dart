import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitlyf/providers/workout_provider.dart';
import 'package:fitlyf/widgets/frosted_glass_card.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class WeightDetailScreen extends StatelessWidget {
  const WeightDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutProvider>(
      builder: (context, workoutProvider, child) {
        // *** FIX 1: Correctly get the weight history from the provider ***
        // It's a List<WeightLog>, not a Map.
        final weightHistory = workoutProvider.weightHistory;
        // Your original logic to sort the list for display (newest first)
        final sortedListForDisplay = List<WeightLog>.from(weightHistory)
          ..sort((a, b) => b.date.compareTo(a.date));

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
              title: const Text('Weight Analytics'),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  // Your original chart card, now with corrected data
                  child: _buildWeightChartCard(context, weightHistory),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    "History",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  // Your original history list, now using the sorted data
                  child: _buildWeightHistoryList(context, sortedListForDisplay),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Your original _buildWeightHistoryList, with the input type changed to List<WeightLog>
  Widget _buildWeightHistoryList(BuildContext context, List<WeightLog> weightHistory) {
    if (weightHistory.isEmpty) {
      return const Center(child: Text("No weight logged yet.", style: TextStyle(color: Colors.white70)));
    }
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      itemCount: weightHistory.length,
      itemBuilder: (context, index) {
        // *** FIX 2: Use the WeightLog object directly ***
        final log = weightHistory[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: FrostedGlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      // Use log.date instead of entry.key
                      DateFormat('EEEE').format(log.date),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      // Use log.date instead of entry.key
                      DateFormat('d MMMM yyyy').format(log.date),
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  // Use log.weight instead of entry.value
                  "${log.weight.toStringAsFixed(1)} kg",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  // Your original _buildWeightChartCard, with the input type changed to List<WeightLog>
  Widget _buildWeightChartCard(BuildContext context, List<WeightLog> history) {
    // Your original logic to sort the data for the chart (oldest first)
    final sortedHistoryForChart = List<WeightLog>.from(history)..sort((a,b) => a.date.compareTo(b.date));

    return FrostedGlassCard(
      child: AspectRatio(
        aspectRatio: 1.7,
        child: sortedHistoryForChart.length < 2 
            ? const Center(
                child: Text(
                  "Log more than one weight entry to see your chart!",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              )
            : LineChart(
                _buildChartData(context, sortedHistoryForChart),
                duration: const Duration(milliseconds: 400),
              ),
      ),
    );
  }

  // Your original _buildChartData, with logic updated to read from a List<WeightLog>
  LineChartData _buildChartData(BuildContext context, List<WeightLog> weightHistory) {
    // *** FIX 3: Create spots using the index for X and weight for Y ***
    List<FlSpot> spots = weightHistory.asMap().entries.map((entry) {
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
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, interval: 2)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: (spots.length / 4).ceil().toDouble(), // Your logic for label spacing
            getTitlesWidget: (value, meta) {
              int index = value.toInt();
              // *** FIX 4: Use the index to safely get the date from the history list ***
              if (index >= 0 && index < weightHistory.length) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 8.0,
                  child: Text(DateFormat('d MMM').format(weightHistory[index].date), style: const TextStyle(fontSize: 12, color: Colors.white70)),
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
      maxX: (spots.length - 1).toDouble(), // Use index-based max X
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: Colors.white,
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                Colors.deepPurple.withOpacity(0.5),
                Colors.deepPurple.withOpacity(0.0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }
}
