import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:fitlyf/providers/workout_provider.dart';
import 'package:fitlyf/widgets/frosted_glass_card.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class WeightDetailScreen extends StatelessWidget {
  const WeightDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final workoutProvider = Provider.of<WorkoutProvider>(context);
    final weightHistory = workoutProvider.weightHistory.entries.toList();
    weightHistory.sort((a, b) => b.key.compareTo(a.key));

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
              child: _buildWeightHistoryList(context, weightHistory),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightHistoryList(BuildContext context, List<MapEntry<DateTime, double>> weightHistory) {
    if (weightHistory.isEmpty) {
      return const Center(child: Text("No weight logged yet.", style: TextStyle(color: Colors.white70)));
    }
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      itemCount: weightHistory.length,
      itemBuilder: (context, index) {
        final entry = weightHistory[index];
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
                      DateFormat('EEEE').format(entry.key),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      DateFormat('d MMMM yyyy').format(entry.key),
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  "${entry.value.toStringAsFixed(1)} kg",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeightChartCard(BuildContext context, List<MapEntry<DateTime, double>> history) {
    final sortedHistory = List<MapEntry<DateTime, double>>.from(history)..sort((a,b) => a.key.compareTo(b.key));

    return FrostedGlassCard(
      child: AspectRatio(
        aspectRatio: 1.7,
        child: sortedHistory.length < 2 
            ? const Center(
                child: Text(
                  "Log more than one weight entry to see your chart!",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              )
            : LineChart(_buildChartData(context, sortedHistory)),
      ),
    );
  }

  LineChartData _buildChartData(BuildContext context, List<MapEntry<DateTime, double>> weightHistory) {
    // THE FIX: This now correctly maps the DateTime to the x-axis.
    List<FlSpot> spots = weightHistory.map((entry) {
      return FlSpot(entry.key.millisecondsSinceEpoch.toDouble(), entry.value);
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
            interval: (spots.length > 1 ? (spots.last.x - spots.first.x) / 4 : 1),
            getTitlesWidget: (value, meta) {
              DateTime date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
              return SideTitleWidget(
                axisSide: meta.axisSide,
                space: 8.0,
                child: Text(DateFormat('d MMM').format(date), style: const TextStyle(fontSize: 12)),
              );
            },
          ),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: true, border: Border.all(color: Colors.white24)),
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
