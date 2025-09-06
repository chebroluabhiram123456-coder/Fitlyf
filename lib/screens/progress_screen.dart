import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitlyf/providers/workout_provider.dart';
import 'package:fitlyf/widgets/frosted_glass_card.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:fitlyf/screens/weight_detail_screen.dart'; // Import the new screen

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutProvider>(
      builder: (context, workoutProvider, child) {
        final weightHistory = workoutProvider.weightHistory.entries.toList();
        weightHistory.sort((a, b) => a.key.compareTo(b.key));
        
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
                  const Text("Weight Analytics", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 20),
                  // THE FIX 1: Make the chart card tappable
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const WeightDetailScreen()),
                      );
                    },
                    child: _buildWeightChartCard(context, weightHistory),
                  ),
                  const SizedBox(height: 30),
                  const Text("Workout Stats", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 20),
                  _buildStatsCard(context, completedExercises, totalExercises),
                  const SizedBox(height: 30),
                  
                  // THE FIX 2: Add the new streak calendar
                  const Text("Workout Streak", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 20),
                  _buildStreakCalendar(context, workoutProvider),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // THE FIX 3: New widget for the frosted glass calendar
  Widget _buildStreakCalendar(BuildContext context, WorkoutProvider provider) {
    final today = DateTime.now();
    final firstDayOfMonth = DateTime(today.year, today.month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(today.year, today.month);
    // weekday returns 1 for Monday, 7 for Sunday. We adjust for 0-indexed list.
    final startingWeekday = firstDayOfMonth.weekday - 1; 

    return FrostedGlassCard(
      child: Column(
        children: [
          Text(DateFormat('MMMM yyyy').format(today), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su']
                .map((day) => Text(day, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)))
                .toList(),
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
            itemCount: daysInMonth + startingWeekday,
            itemBuilder: (context, index) {
              if (index < startingWeekday) {
                return const SizedBox.shrink(); // Empty space for days before the 1st
              }
              final dayOfMonth = index - startingWeekday + 1;
              final date = DateTime(today.year, today.month, dayOfMonth);
              final status = provider.getWorkoutStatusForDate(date);

              IconData? icon;
              Color? iconColor;
              if (status == WorkoutStatus.Completed) {
                icon = Icons.check_circle;
                iconColor = Colors.greenAccent;
              } else if (status == WorkoutStatus.Skipped) {
                icon = Icons.cancel;
                iconColor = Colors.redAccent;
              }

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(dayOfMonth.toString()),
                  if (icon != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: Icon(icon, color: iconColor, size: 14),
                    ),
                ],
              );
            },
          )
        ],
      ),
    );
  }

  // ... other helper methods are unchanged ...
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

  Widget _buildStatsCard(BuildContext context, int completed, int total) {
    double percentage = total > 0 ? (completed / total) * 100 : 0;
    return FrostedGlassCard(
      padding: const EdgeInsets.all(25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(children: [
              Text("$completed / $total", style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold)),
              const Text("Exercises Done", style: TextStyle(color: Colors.white70)),
          ]),
          Column(children: [
              Text("${percentage.toStringAsFixed(0)}%", style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold)),
              const Text("Completion", style: TextStyle(color: Colors.white70)),
          ]),
        ],
      ),
    );
  }

  LineChartData _buildChartData(BuildContext context, List<MapEntry<DateTime, double>> weightHistory) {
    List<FlSpot> spots = weightHistory.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.value);
    }).toList();
    return LineChartData( /* ... chart data is unchanged ... */
      gridData: FlGridData(show: true, drawVerticalLine: true, getDrawingHorizontalLine: (value) => const FlLine(color: Colors.white24, strokeWidth: 0.8), getDrawingVerticalLine: (value) => const FlLine(color: Colors.white24, strokeWidth: 0.8)),
      titlesData: FlTitlesData(
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, interval: 2, getTitlesWidget: defaultGetTitle)),
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, interval: (spots.length / 4).ceil().toDouble(), getTitlesWidget: (value, meta) {
              int index = value.toInt();
              if (index >= 0 && index < weightHistory.length) {
                return SideTitleWidget(axisSide: meta.axisSide, space: 8.0, child: Text(DateFormat('d MMM').format(weightHistory[index].key), style: const TextStyle(fontSize: 12)));
              }
              return const Text('');
        })),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: true, border: Border.all(color: Colors.white24)),
      minX: 0, maxX: (spots.length - 1).toDouble(),
      lineBarsData: [
        LineChartBarData(
          spots: spots, isCurved: true, color: Colors.white, barWidth: 5, isStrokeCapRound: true, dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(show: true, gradient: LinearGradient(colors: [ Colors.deepPurple.withOpacity(0.5), Colors.deepPurple.withOpacity(0.0) ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        ),
      ],
    );
  }
}
