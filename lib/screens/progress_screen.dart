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
        
        // This getter is now "session-aware" and provides live data.
        final todaysWorkout = workoutProvider.getTodaysWorkout;

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
                  
                  _buildStatsSection(context, todaysWorkout),

                  const SizedBox(height: 30),
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
  
  Widget _buildStatsSection(BuildContext context, Workout? todaysWorkout) {
    if (todaysWorkout == null) {
      return Column( crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("Today's Stats", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 20),
          const FrostedGlassCard(child: Center(child: Padding(padding: EdgeInsets.all(25.0), child: Text("It's a Rest Day!", style: TextStyle(fontSize: 18, color: Colors.white70))))),
      ]);
    }

    // Because the provider is now smarter, these stats will be live.
    final completedExercises = todaysWorkout.exercises.where((ex) => ex.isCompleted).length;
    final totalExercises = todaysWorkout.exercises.length;
    
    return Column( crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text("Today's Stats: ${todaysWorkout.name}", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 20),
        _buildStatsCard(context, completedExercises, totalExercises),
    ]);
  }

  // ... All other helper methods are unchanged and correct ...
  Widget _buildStreakCalendar(BuildContext context, WorkoutProvider provider) { /* ... */ }
  Widget _buildWeightChartCard(BuildContext context, List<MapEntry<DateTime, double>> history) { /* ... */ }
  Widget _buildStatsCard(BuildContext context, int completed, int total) { /* ... */ }
  LineChartData _buildChartData(BuildContext context, List<MapEntry<DateTime, double>> weightHistory) { /* ... */ }
}
