import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitlyf/providers/workout_provider.dart';
import 'package:fitlyf/widgets/frosted_glass_card.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:fitlyf/screens/weight_detail_screen.dart';
import 'package:fitlyf/helpers/fade_route.dart';
import 'package:fitlyf/screens/workout_history_screen.dart';
import 'package:fitlyf/models/workout_model.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutProvider>(
      builder: (context, workoutProvider, child) {
        final weightHistory = workoutProvider.weightHistory.entries.toList();
        weightHistory.sort((a, b) => a.key.compareTo(b.key));
        
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
                  const Text("Weight Analytics", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, FadePageRoute(child: const WeightDetailScreen()));
                    },
                    child: _buildWeightChartCard(context, weightHistory),
                  ),
                  const SizedBox(height: 30),
                  
                  // THE FIX: The entire "Workout Stats" section has been removed.

                  const Text("Workout Streak", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                       Navigator.push(context, FadePageRoute(child: const WorkoutHistoryScreen()));
                    },
                    child: _buildStreakCalendar(context, workoutProvider),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  // --- Helper methods are unchanged ---
  
  Widget _buildStreakCalendar(BuildContext context, WorkoutProvider provider) {
    final today = DateTime.now();
    final firstDayOfMonth = DateTime(today.year, today.month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(today.year, today.month);
    final startingWeekday = firstDayOfMonth.weekday - 1; 
    return FrostedGlassCard(
      child: Column( children: [
          Text(DateFormat('MMMM yyyy').format(today), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          Row( mainAxisAlignment: MainAxisAlignment.spaceAround, children: ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'].map((day) => Text(day, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold))).toList()),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
            itemCount: daysInMonth + startingWeekday,
            itemBuilder: (context, index) {
              if (index < startingWeekday) return const SizedBox.shrink();
              final dayOfMonth = index - startingWeekday + 1;
              final date = DateTime(today.year, today.month, dayOfMonth);
              final status = provider.getWorkoutStatusForDate(date);
              IconData? icon; Color? iconColor;
              if (status == WorkoutStatus.Completed) { icon = Icons.check_circle; iconColor = Colors.greenAccent; }
              else if (status == WorkoutStatus.Skipped) { icon = Icons.cancel; iconColor = Colors.redAccent; }
              return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(dayOfMonth.toString()),
                  if (icon != null) Padding(padding: const EdgeInsets.only(top: 2.0), child: Icon(icon, color: iconColor, size: 14)),
              ]);
            },
          )
      ]),
    );
  }
  Widget _buildWeightChartCard(BuildContext context, List<MapEntry<DateTime, double>> history) {
    return FrostedGlassCard(
      child: AspectRatio(
        aspectRatio: 1.7,
        child: history.length < 2 
            ? const Center(child: Text("Log more to see your chart!\n(Tap here for details)", textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 16)))
            : LineChart(_buildChartData(context, history)),
      ),
    );
  }

  LineChartData _buildChartData(BuildContext context, List<MapEntry<DateTime, double>> weightHistory) {
    List<FlSpot> spots = weightHistory.map((entry) => FlSpot(entry.key.millisecondsSinceEpoch.toDouble(), entry.value)).toList();
    return LineChartData(
      gridData: FlGridData(show: true, drawVerticalLine: true, getDrawingHorizontalLine: (value) => const FlLine(color: Colors.white24, strokeWidth: 0.8), getDrawingVerticalLine: (value) => const FlLine(color: Colors.white24, strokeWidth: 0.8)),
      titlesData: FlTitlesData(
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, interval: 2)),
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, interval: (spots.length > 1 ? (spots.last.x - spots.first.x) / 4 : 1), getTitlesWidget: (value, meta) {
              DateTime date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
              return SideTitleWidget(axisSide: meta.axisSide, space: 8.0, child: Text(DateFormat('d MMM').format(date), style: const TextStyle(fontSize: 12)));
        })),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: true, border: Border.all(color: Colors.white24)),
      lineBarsData: [
        LineChartBarData(
          spots: spots, isCurved: true, color: Colors.white, barWidth: 5, isStrokeCapRound: true, dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(show: true, gradient: LinearGradient(colors: [ Colors.deepPurple.withOpacity(0.5), Colors.deepPurple.withOpacity(0.0) ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        ),
      ],
    );
  }
}
